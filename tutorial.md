# LISA 2019 Linux System Troubleshooting Tutorial

## Installation

The [GitHub](https://github.com) repository contains a
[Vagrant](https://vagrantup.com) configuration file used to build the Virtual
Machines (VMs) we will use in this tutorial.  [Ansible](https://ansible.com) is
used to perform post configuration on the VMs.  You will need to download the
following tools to complete the installation:
  * [Git](https://git-scm.com/downloads)
  * [Vagrant](https://www.vagrantup.com/downloads.html)
  * [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html?extIdCarryOver=true&sc_cid=701f2000001OH7YAAW)
  * [VirtualBox\*](https://www.virtualbox.org/wiki/Downloads)

\* VirtualBox is used as the Virtualization provider, other providers work
equally well (i.e. VMWare, kvm).  

If you are using VirtualBox, the following Vagrant plugins are useful:

  * vagrant-hostmanager
  * vagrant-vbguest

You may install these by executing the following commands:

```bash
$ vagrant plugin install vagrant-hostmanager
```

To provision the main VM used in the examples, execute the following:
```bash
$ vagrant up getip
```

### Checkout troubleshooting repository

The [troubleshooting](origin
https://github.com/uphillian/troubleshootinglinux.git) repository is a separate
repository.  To pull in this repository, first glone this repository, then use
`git submodule` to pull in the troubleshooting repository.

```bash
$ git clone https://github.com/uphillian/lisa2019.git
$ cd lisa2019
$ git submodule init
$ git submodule update
```


### Virtual Machine

After provisioning has completed, ssh into the test machine and
change to the troubleshooting directory.

```bash
$ vagrant ssh getip
$ cd /vagrant/troubleshootinglinux
```

## Overview / Kernel

The kernel is the first process started by the boot loader.  Computer Scientists
start numbering at 0, so the kernel is process 0.  The first process the kernel
starts is the init process.  This is process 1.  Init is in charge of starting
all the other processes on the system.  Various init programs exist, system V
init, upstart, launchd and systemd are a few.  Processes are monitored in a
process table.  The kernel exposes the process table in the /proc filesystem.
The kernel has various internal processes that are also shown in the process
table.

## UNIX / Linux

Linux is a clone of UNIX.  UNIX was created at a time when resources were very
tight.  This isn't a bad thing.  There were various design decisions made to
conserve space.  Early on in the development, several low level operations were
identified.  These operations would be needed by many different programs.  To
reduce the redundancy in the system, early UNIX designed a system of shared
libraries that should be used to perform the common operations.  The kernel
would handle some of these operations, those operations that required special
access to hardware such as opening and writing to files.  The calls performed by
the kernel are known as System calls or syscalls.

### syscalls

There were originally 34 syscalls.  These are things such as open, close, write.

**Try it:**

```bash
$ man syscalls
```

### glibc / libc

Instead of repeating the code to perform syscalls, a library was created to
contain all the "wrapper" functions, this library was known as the C-Library or
libc.  The wrapper functions set up memory and arguments for the kernel calls to
complete and return the results to the calling application.  The GNU
organisation reimplemented the C-Library, this is known as the GNU C-Library or
glibc.  Since every application on the system will need to use the functions
contained in glibc, the version installed on a system is very important.  To
obtain the version installed on your system, simply execute the library.  To
determine the location of your glibc, run `ldd` on an executable.

**Try it:**

```bash
$ ldd /bin/bash
	linux-vdso.so.1 (0x00007ffffd1d5000)
	libtinfo.so.6 => /lib64/libtinfo.so.6 (0x00007ffacb957000)
	libdl.so.2 => /lib64/libdl.so.2 (0x00007ffacb951000)
	libc.so.6 => /lib64/libc.so.6 (0x00007ffacb78b000)
	/lib64/ld-linux-x86-64.so.2 (0x00007ffacbad1000)
$ /lib64/libc.so.6
GNU C Library (GNU libc) stable release version 2.29.
Copyright (C) 2019 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.
There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
Compiled by GNU CC version 9.2.1 20190827 (Red Hat 9.2.1-1).
libc ABIs: UNIQUE IFUNC ABSOLUTE
For bug reporting instructions, please see:
<http://www.gnu.org/software/libc/bugs.html>.
```

#### ltrace

No troubleshooting talk is complete without mention of tracing.  Tracing is the
ability to intercept the dynamic calls of a running process.  There are two
flavours of tracing, system tracing and library tracing.  You may intercept
system calls with `strace` and library calls with `ltrace`.  To intercept *both*
you may use `ltrace -S`.

**Try it:**

```C
$ ltrace /bin/hostname
__libc_start_main(0x401230, 1, 0x7ffcd2f83c98, 0x401ea0 <unfinished ...>
rindex("/bin/hostname", '/')                                                                               = "/hostname"
strcmp("hostname", "domainname")                                                                           = 4
strcmp("hostname", "ypdomainname")                                                                         = -17
strcmp("hostname", "nisdomainname")                                                                        = -6
getopt_long(1, 0x7ffcd2f83c98, "aAdfbF:h?iIsVy", 0x4028a0, nil)                                            = -1
__errno_location()                                                                                         = 0x7f94afb926b0
malloc(128)                                                                                                = 0xecf010
gethostname("localhost.localdomain", 128)                                                                  = 0
memchr("localhost.localdomain", '\0', 128)                                                                 = 0xecf025
puts("localhost.localdomain"localhost.localdomain
)                                                                              = 22
+++ exited (status 0) +++
$ ltrace -S /bin/hostname
open@SYS("/lib64/libc.so.6", 524288, 030024570520)                                                         = 3
read@SYS(3, "\177ELF\002\001\001\003", 832)                                                                = 832
fstat@SYS(3, 0x7fff2e6c93f0)                                                                               = 0
mmap@SYS(nil, 3985888, 5, 2050, 3, 0)                                                                      = 0x7fb7bfd24000
mprotect@SYS(0x7fb7bfee7000, 2097152, 0)                                                                   = 0
mmap@SYS(0x7fb7c00e7000, 24576, 3, 2066, 3, 1847296)                                                       = 0x7fb7c00e7000
mmap@SYS(0x7fb7c00ed000, 16864, 3, 50, -1, 0)                                                              = 0x7fb7c00ed000
...
```

#### ELF / Linker (ld.so)

Linux uses Executable and Linkable Format (ELF) binaries.  ELF binaries contain
information that can be used to determine which libraries and versions of
libraries are required to execute the program.  This information is handled by
the linker (ld.so).  Every dynamic binary on the system requires the linker to
find the libraries required for it's execution, so when we run `ldd` on a file,
one of the libraries returned is the linker.

```bash
$ ldd /bin/bash |grep ld
	/lib64/ld-linux-x86-64.so.2 (0x00007fc4a977f000)
```

The manual page for the linker is ld.so

```bash
$ man ld.so
```

##### LD\_PRELOAD

It is sometimes useful to intercept a library call and replace it with your own
function.  This is possible with the `LD_PRELOAD` environment variable.  When
this environment variable is available, it specifies a list of additional ELF
shared libraries to be loaded before all others. 

##### LD\_PROFILE

You can profile any shared library by setting LD\_PROFILE to the name of the
library.  Profiling yields information about how often a call is used and how
long the call takes to execute.

```
# LD_PROFILE=libc.so.6 hostname
# sprof /lib64/libc.so.6 /var/tmp/libc.so.6.profile 
Flat profile:

Each sample counts as 0.01 seconds.
  %   cumulative   self              self     total
 time   seconds   seconds    calls  us/call  us/call  name
  0.00      0.00     0.00        3     0.00           __strcmp_sse42
  0.00      0.00     0.00        1     0.00           __GI___errno_location
  0.00      0.00     0.00        1     0.00           __libc_start_main
  0.00      0.00     0.00        1     0.00           __strrchr_sse42
  0.00      0.00     0.00        1     0.00           gethostname
  0.00      0.00     0.00        1     0.00           getopt_long
  0.00      0.00     0.00        1     0.00           malloc
  0.00      0.00     0.00        1     0.00           memchr
  0.00      0.00     0.00        1     0.00           puts
```

### Processes

#### Fork

Processes are created via the fork system call.  
```bash
$ man fork
```

A lot of the terminology used in UNIX has a familial root.
When a process is created via fork, the new process (the child) receives a full
copy of the memory of the creating process (the parent).  When the parent
process is terminated (dies), the child is referred to as an orphan.  Orphaned
processes are "reaped" by the init process, the parent of the reaped processes
becomes the init process.   

```bash
$ ./fork.py &
$ psg python
```

#### Signals

Processes communicate with one another using signals.  Signals are passed
between processes using the `kill` command.  The kill command by default sends
the SIGTERM (15) or terminate signal.  Many other signals exist, a commonly used
signal is SIGKILL (9). 
A list of available signals is obtained via `kill -l`.

**Try it:**

```bash
$ kill -l
 1) SIGHUP	 2) SIGINT	 3) SIGQUIT	 4) SIGILL	 5) SIGTRAP
 6) SIGABRT	 7) SIGBUS	 8) SIGFPE	 9) SIGKILL	10) SIGUSR1
11) SIGSEGV	12) SIGUSR2	13) SIGPIPE	14) SIGALRM	15) SIGTERM
16) SIGSTKFLT	17) SIGCHLD	18) SIGCONT	19) SIGSTOP	20) SIGTSTP
21) SIGTTIN	22) SIGTTOU	23) SIGURG	24) SIGXCPU	25) SIGXFSZ
26) SIGVTALRM	27) SIGPROF	28) SIGWINCH	29) SIGIO	30) SIGPWR
31) SIGSYS	34) SIGRTMIN	35) SIGRTMIN+1	36) SIGRTMIN+2	37) SIGRTMIN+3
38) SIGRTMIN+4	39) SIGRTMIN+5	40) SIGRTMIN+6	41) SIGRTMIN+7	42) SIGRTMIN+8
43) SIGRTMIN+9	44) SIGRTMIN+10	45) SIGRTMIN+11	46) SIGRTMIN+12	47) SIGRTMIN+13
48) SIGRTMIN+14	49) SIGRTMIN+15	50) SIGRTMAX-14	51) SIGRTMAX-13	52) SIGRTMAX-12
53) SIGRTMAX-11	54) SIGRTMAX-10	55) SIGRTMAX-9	56) SIGRTMAX-8	57) SIGRTMAX-7
58) SIGRTMAX-6	59) SIGRTMAX-5	60) SIGRTMAX-4	61) SIGRTMAX-3	62) SIGRTMAX-2
63) SIGRTMAX-1	64) SIGRTMAX
```
#### Zombie

When a child terminates it is expected to send the signal SIGCHILD (17) to it's
parent.  If the parent fails to receive this signal, the child remains in the
process table but is no longer a running process.  This is normally not a
problem, however, the Zombie (defunct) process counts as an open file.  If a
user has 1000 defunct processes, they have 1000 open files.  This is a problem
where **limits** are enforced.

To illustrate, a python program is included, run the process to create a zombie.

**Try it**:

```bash
$ ./zombie.py &
$ psg python
 8594 14374 S    python ./zombie.py
14374 14384 Z    [python] <defunct>
$ kill -SIGALRM 14384
Received 14
Zombie is gone

[1]+  Done                    ./zombie.py
```

## Name Service Switch

UNIX was created at a time when there were fewer computers and even fewer
computers on any given network.  Hosts in the network are identified by their IP
Address (ipaddress).  A list of ipaddresses of machines is held in `/etc/hosts`.
Originally this was sufficient since the list was managable, often fewer than
100 hosts were listed in this file.  However, the network grew and the Internet
changed this into thousands of hosts.  A system of dynamic name resolution (DNS)
was developed.  Instead of consulting the `/etc/hosts` file, a DNS server was
consulted.  To allow the system to continue using the `/etc/hosts` file and the
DNS servers side-by-side, the name service switch (nss) system was developed.
When the system needs to lookup a host it consults `/etc/nsswitch.conf` to
determine which  


## Pluggable Authentication Modules (PAM)

The process of logging into a system used to involve simply consulting the local
password file (`/etc/passwd`).  This system proved sufficient for small
installations but over time a better system was needed.  The
`/etc/passwd` file was split into two files `/etc/passwd` and `/etc/shadow` for
security concerns, the `/etc/shadow` file contains the encrypted hashes of the
passwords and it unreadable by regular users.  The `/etc/passwd` file is
readable by all users, this is so that users can determine which other user is
running processes or owns files.

The PAM system allows a set of dynamic libraries to be consulted when a user
attempts to login to the system.  Several backends can be used to determine
the password for a user.   

### Limits

When a process runs on Linux it runs as a specific user and group.  A system of
limits is imposed on the process by pam-limits (`man pam_limits`).  Limits are defined in
`/etc/security/limits.conf`

# Questions / Comments

Feel free to fork the repository and submit a pull request for any errors or
ommisions.  Questions can be sent directly to:

`thomas @ narrabilis dot com`

or:

[@uphillian](https://twitter.com/uphillian)

  To hire our consultants, direct your inquiry to:

consulting@uphillian.com


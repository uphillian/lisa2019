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
```

### Virtual Machine

After provisioning has completed, ssh into the test machine and
change to the troubleshooting directory.

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
* Try it

```bash
$ man syscalls
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
A list of available signals is obtained via 
#### Zombie

When a child dies it is expected to send the signal SIGCHILD (17)
## ltrace

Run ltrace 
## The Linker ld.so

### LD\_PROFILE

You can profile any shared library by setting LD\_PROFILE to the name of the library.
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


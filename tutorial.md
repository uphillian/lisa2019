# LISA 2019 Linux System Troubleshooting Tutorial

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


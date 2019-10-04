#!/bin/bash

# start tmux first
tmux new-session -c /home/thomas/lisa2019 -s lisa
tmux neww -n glibc
tmux neww -n vagrant

# start ttyd
./ttyd-start 

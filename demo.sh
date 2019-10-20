#!/bin/bash

# start tmux first
tmux new-session -c /home/thomas/lisa2019 -s lisa
tmux neww -n glibc
tmux neww -n vagrant
tmux neww -n ttyd

# start ttyd
./ttyd-start 

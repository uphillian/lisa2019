#!/bin/bash

# start tmux first
tmux new-session -c /home/thomas/lisa2019 -s lisa
tmux neww -n glibc
tmux neww -n vagrant

# start ttyd
ttyd -p 8081 -t fontSize=24 tmux attach -t lisa 2>&1 >/tmp/ttyd &

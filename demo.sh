#!/bin/bash

# start tmux first
tmux new-session -s lisa

# start ttyd
ttyd -p 8081 -t fontSize=24 tmux attach -t lisa 2>&1 >/tmp/ttyd &

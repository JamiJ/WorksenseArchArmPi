#!/bin/bash
export XAUTHORITY=/home/alarm/.Xauthority
export DISPLAY=:0
DISPLAY=:0 xdotool key ctrl+F5
./nettest.sh

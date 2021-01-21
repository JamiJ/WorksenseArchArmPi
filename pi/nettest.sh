#!/bin/bash

sleep 6000
if ping -q -c 5 -W 5 8.8.8.8 >/dev/null; then
  ./chromium_restart.sh
else
  reboot
fi

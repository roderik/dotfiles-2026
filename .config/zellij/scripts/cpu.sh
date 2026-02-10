#!/bin/bash
/usr/bin/top -l 1 -n 0 2>/dev/null | /usr/bin/awk '/CPU usage/ {print $3}'

#!/bin/bash
/usr/bin/memory_pressure 2>/dev/null | /usr/bin/awk '/percentage/ {print $5}'

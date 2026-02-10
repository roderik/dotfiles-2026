#!/bin/bash
cd "${1:-.}" 2>/dev/null || exit 0

# Use worktrunk statusline if available (includes branch, status, CI)
if command -v wt &>/dev/null; then
    line=$(wt list statusline 2>/dev/null | /usr/bin/perl -pe 's/\e\[[0-9;]*m//g' | /usr/bin/sed 's/^[[:space:]]*//' | /usr/bin/sed 's/[[:space:]]*$//')
    if [ -n "$line" ]; then
        echo "$line"
        exit 0
    fi
fi

# Fallback: plain git branch
git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '—'

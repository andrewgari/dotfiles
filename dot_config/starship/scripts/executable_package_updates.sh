#!/bin/bash

# Quick check for DNF updates (without full metadata refresh)
dnf_updates=$(dnf list updates 2>/dev/null | tail -n +3 | wc -l)

# Fast Flatpak update check
flatpak_updates=$(flatpak remote-ls --updates 2>/dev/null | wc -l)

# Calculate total updates
total_updates=$((dnf_updates + flatpak_updates))

# Show updates if available
if [[ $total_updates -gt 0 ]]; then
    echo " $total_updates"
fi

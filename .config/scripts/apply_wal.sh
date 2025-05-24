#!/bin/bash

THEME_FILE="/tmp/theme_variant"
wal_arguments=""

if [ -s "$THEME_FILE" ]; then
  case $(<"$THEME_FILE") in
    "light") wal_arguments="lighten -l" ;;
  esac
fi

wal -i ~/Pictures/wallpapers/sky.png --cols16 $wal_arguments -q -n -e

# Refresh Waybar
if pgrep -x "waybar" >/dev/null; then
    killall waybar
fi
waybar &

# Reload kitty theme
kitty @ set-colors --all ~/.cache/wal/colors-kitty.conf

# Restart swaync
swaync-client -rs



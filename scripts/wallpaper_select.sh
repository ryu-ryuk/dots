#!/bin/bash

WALL="$HOME/Pictures/wallpapers/sky.png"

# Start swww if not running
pgrep -x swww-daemon >/dev/null || swww-daemon & sleep 0.5

# Animate wallpaper change
swww img "$WALL" \
  --transition-type grow \
  --transition-pos "$(hyprctl cursorpos)" \
  --transition-duration 0.7 \
  --transition-fps 60


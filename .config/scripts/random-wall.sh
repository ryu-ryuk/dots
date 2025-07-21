#!/bin/bash

sleep 0.1

MONITOR="eDP-1"
IMAGE_DIR="$HOME/Pictures/wallpapers"

# Find a random static image
RANDOM_WALLPAPER=$(find "$IMAGE_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n 1)

# Set the new wallpaper using a command
if [ -n "$RANDOM_WALLPAPER" ]; then
    hyprctl hyprpaper preload "$RANDOM_WALLPAPER"
    hyprctl hyprpaper wallpaper "$MONITOR,$RANDOM_WALLPAPER"
fi

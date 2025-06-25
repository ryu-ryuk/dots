#!/bin/bash

# Set config paths
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_DIR="$XDG_CONFIG_HOME/scripts"
RofiConf="$XDG_CONFIG_HOME/rofi/wallpaper-select.rasi"
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
APPLY_WAL="$HOME/.config/scripts/apply_wal.sh"
CHOOSER="Wallpaper selector"

# Validate paths
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send -a "$CHOOSER" "Error" "Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
fi

if [ ! -f "$RofiConf" ]; then
    notify-send -a "$CHOOSER" "Error" "Rofi config not found: $RofiConf"
    exit 1
fi

if [ ! -x "$CONFIG_DIR/switch-wall.sh" ]; then
    notify-send -a "$CHOOSER" "Error" "switch-wall.sh not found or not executable: $CONFIG_DIR/switch-wall.sh"
    exit 1
fi

# Process and display wallpapers with shortened names
imgpath=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf | while read -r file; do
    filename=$(basename "$file")
    short_name=$(echo "${filename%.*}" | cut -c 1-15)
    if [ "${#filename}" -gt 15 ]; then
        short_name="${short_name}..."
    fi
    echo -en "$file\x00icon\x1f$file\x1finfo\x1f$short_name\n"
done | rofi -dmenu -theme "$RofiConf" -show-icons)

# Check if a wallpaper was selected
if [ -z "$imgpath" ]; then
    notify-send -a "$CHOOSER" "Info" "No wallpaper selected"
    exit 0
fi

# Apply wallpaper
if ! "$CONFIG_DIR/switch-wall.sh" "$imgpath"; then
    notify-send -a "$CHOOSER" "Error" "Failed to apply wallpaper: $imgpath"
    exit 1
fi

apply_wal_theme() {
    local image="$1"
    if [ -x "$APPLY_WAL" ]; then
        "$APPLY_WAL" "$image" || notify-send -a "$CHOOSER" "Error" "Failed to apply wal theme"
    else
        notify-send -a "$CHOOSER" "Error" "apply_wal.sh not found or not executable: $APPLY_WAL"
        exit 1
    fi
}

apply_wal_theme "$imgpath"


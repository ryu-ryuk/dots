#!/bin/bash
# Set config paths
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_DIR="$XDG_CONFIG_HOME/scripts"
HYPRPAPER_CONF="$XDG_CONFIG_HOME/hypr/hyprpaper.conf"

switch() {
    imgpath=$1
    if [ -z "$imgpath" ]; then
        echo "No valid wallpaper selected!"
        exit 1
    fi

    # Kill hyprpaper if it's running
    pkill hyprpaper

    # Simple update of hyprpaper.conf with sed
    # First backup the original
    cp "$HYPRPAPER_CONF" "${HYPRPAPER_CONF}.bak"

    # Replace preload line
    sed -i "s|^preload =.*|preload = $imgpath|" "$HYPRPAPER_CONF"

    # Replace wallpaper line
    sed -i "s|^wallpaper =.*|wallpaper = eDP-1,$imgpath|" "$HYPRPAPER_CONF"

    # Start hyprpaper fresh with the new config
    hyprpaper &
    disown

    # Send notification
    notify-send -a "Wallpaper" -i "$imgpath" "Changed~" "$(basename "$imgpath")"
}

# Only switch if an argument is given
if [[ -n "$1" ]]; then
    switch "$1"
else
    echo "Give me a wallpaper, will you?"
    exit 0
fi

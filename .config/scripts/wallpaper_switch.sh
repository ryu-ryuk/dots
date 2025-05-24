#!/usr/bin/env bash

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
WALLPAPER_DIR="$HOME/Pictures/wallpapers" 
CHOOSER="Wallpaper selector"

# Check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validate dependencies
check_dependencies() {
    local deps=("hyprctl" "swww" "jq" "bc" "notify-send")
    local missing=()
    for dep in "${deps[@]}"; do
        command_exists "$dep" || missing+=("$dep")
    done
    if [ ${#missing[@]} -gt 0 ]; then
        notify-send -a "$CHOOSER" "Error" "Missing dependencies: ${missing[*]}"
        exit 1
    fi
}

# Switch wallpaper
switch() {
    local imgpath="$1"
    if [ -z "$imgpath" ] || [ ! -f "$imgpath" ]; then
        notify-send -a "$CHOOSER" "Error" "Invalid or missing image: $imgpath"
        exit 1
    fi

    # Get monitor and cursor info
    local scale screenx screeny screensizey cursorposx cursorposy
    read -r scale screenx screeny screensizey < <(hyprctl monitors -j | jq '.[] | select(.focused) | .scale, .x, .y, .height' | xargs)
    if [ -z "$scale" ]; then
        notify-send -a "$CHOOSER" "Error" "Failed to get monitor info"
        exit 1
    fi

    cursorposx=$(hyprctl cursorpos -j | jq '.x' 2>/dev/null || echo 960)
    cursorposy=$(hyprctl cursorpos -j | jq '.y' 2>/dev/null || echo 540)
    cursorposx=$(bc <<< "scale=0; ($cursorposx - $screenx) * $scale / 1")
    cursorposy=$(bc <<< "scale=0; ($cursorposy - $screeny) * $scale / 1")
    cursorposy_inverted=$((screensizey - cursorposy))

    # Set wallpaper with swww
    if ! swww img "$imgpath" --transition-step 100 --transition-fps 120 \
        --transition-type grow --transition-angle 30 --transition-duration 1 \
        --transition-pos "$cursorposx,$cursorposy_inverted"; then
        notify-send -a "$CHOOSER" "Error" "Failed to set wallpaper"
        exit 1
    fi
}


# Main execution
check_dependencies

if [ "$1" == "--noswitch" ]; then
    imgpath=$(swww query | awk -F 'image: ' '{print $2}' | head -n 1)
    if [ -z "$imgpath" ]; then
        notify-send -a "$CHOOSER" "Error" "Could not query current wallpaper"
        exit 1
    fi
elif [ -n "$1" ]; then
    switch "$1"
else
    # Fallback to yad for manual selection
    if ! command_exists yad; then
        notify-send -a "$CHOOSER" "Error" "yad not installed for wallpaper selection"
        exit 1
    fi
    if [ ! -d "$WALLPAPER_DIR" ]; then
        notify-send -a "$CHOOSER" "Error" "Wallpaper directory not found: $WALLPAPER_DIR"
        exit 1
    fi
    cd "$WALLPAPER_DIR" || exit 1
    imgpath=$(yad --width 1200 --height 800 --file --add-preview --large-preview --title='Choose wallpaper' 2>/dev/null)
    if [ -n "$imgpath" ]; then
        switch "$imgpath"
    else
        notify-send -a "$CHOOSER" "Info" "No wallpaper selected"
        exit 0
    fi
fi

generate_colors "$imgpath"
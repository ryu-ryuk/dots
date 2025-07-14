#!/bin/bash

IMAGE_DIR="$HOME/Pictures/wallpapers"
PLACEHOLDER_IMG="$IMAGE_DIR/sky.png"
CHOOSER="Wallpaper selector"
SET_SCR="$HOME/.config/scripts/switch-wall.sh"
APPLY_WAL="$HOME/.config/scripts/apply_wal.sh" # for pywal

exec 2>> ~/.cache/wallpaper_errors.log

validate_image_directory() {
    if [ ! -d "$IMAGE_DIR" ]; then
        notify-send -a "$CHOOSER" "Error" "Image directory does not exist: $IMAGE_DIR"
        exit 1
    fi
}

validate_images() {
    if [ "$1" -eq 0 ]; then
        notify-send -a "$CHOOSER" "Error" "No images found in $IMAGE_DIR"
        exit 1
    fi
}

select_random_image() {
    local images=("$@")
    local random_image="${images[RANDOM % ${#images[@]}]}"
    if [ ! -f "$PLACEHOLDER_IMG" ] || [ "${#images[@]}" -eq 1 ]; then
        echo "$random_image"
        return
    fi
    local max_attempts=10
    local attempt=0
    while [ "$random_image" -ef "$PLACEHOLDER_IMG" ] && [ "$attempt" -lt "$max_attempts" ]; do
        random_image="${images[RANDOM % ${#images[@]}]}"
        ((attempt++))
    done
    echo "$random_image"
}

set_new_wallpaper() {
    local image="$1"
    if ! ln -sf "$image" "$PLACEHOLDER_IMG"; then
        notify-send -a "$CHOOSER" "Error" "Failed to link wallpaper: $image"
        exit 1
    fi
}

restart_environment() {
    local image="$1"
    if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
        if [ -x "$SET_SCR" ]; then
            "$SET_SCR" "$image" || {
                notify-send -a "$CHOOSER" "Error" "Failed to run switch-wall.sh"
                exit 1
            }
        else
            notify-send -a "$CHOOSER" "Error" "switch-wall.sh not found or not executable: $SET_SCR"
            exit 1
        fi
    fi
}

apply_wal_theme() {
    if [ -x "$APPLY_WAL" ]; then
        "$APPLY_WAL" || notify-send -a "$CHOOSER" "Error" "Failed to apply wal theme"
    else
        notify-send -a "$CHOOSER" "Error" "apply_wal.sh not found or not executable: $APPLY_WAL"
        exit 1
    fi
}

# Main
validate_image_directory
mapfile -t images < <(find "$IMAGE_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \))
validate_images "${#images[@]}"
random_image=$(select_random_image "${images[@]}")
set_new_wallpaper "$random_image"
restart_environment "$random_image"
# apply_wal_theme

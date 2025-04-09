#!/bin/bash

IMAGE_DIR="$HOME/Pictures/wallpapers"
placeholder_img="$HOME/Pictures/wallpapers/sky.png"
chooser="Wallpaper selector"
set_scr="$HOME/.config/scripts/wallpaper_switch.sh"
apply_wal="$HOME/.config/scripts/apply_wal.sh"

validate_image_directory() {
	if [ ! -d "$IMAGE_DIR" ]; then
		notify-send -a "$chooser" "Image directory does not exist" "$IMAGE_DIR"
		exit 1
	fi
}

validate_images() {
	if [ "$1" -eq 0 ]; then
		notify-send -a "$chooser" "No images found" "$IMAGE_DIR"
		exit 1
	fi
}

select_random_image() {
	local random_image="${images[RANDOM % ${#images[@]}]}"
	if [ ! -f "$placeholder_img" ]; then
		echo "$random_image"
	else
		local selected_image
		while :; do
			selected_image="$random_image"
			[ "$selected_image" -ef "$placeholder_img" ] || break
		done
		echo "$selected_image"
	fi
}

set_new_wallpaper() {
	ln -sf "$1" "$placeholder_img"
}

restart_environment() {
	if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
		. "$set_scr"
    fi

}

send_notification() {
    notify-send -a "$chooser" "(∩\`ω´)⊃)) done ; )" -i "$placeholder_img"
}
apply_wal_theme() {
  . "$apply_wal"
}

validate_image_directory
images=("$IMAGE_DIR"/*)
validate_images "${#images[@]}"
random_image=$(select_random_image)
set_new_wallpaper "$random_image"
restart_environment
send_notification
apply_wal_theme

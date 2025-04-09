#!/bin/bash

image_dir="$HOME/Pictures/wallpapers/"
images=("$image_dir"/*)

# Shuffle the image list
shuffled_images=($(printf "%s\n" "${images[@]}" | shuf))

# Build Rofi input
image_list=""
for img in "${shuffled_images[@]}"; do
    image_list+=$(basename "$img" | cut -d. -f1)"\x00icon\x1f${img}\n"
done

# Rofi selection
selected_image=$(printf '%b' "$image_list" | rofi -dmenu -theme ~/.config/rofi/wallpaper-select.rasi -p "select your flavor")

# Resolve full path
for img in "${images[@]}"; do
    if [[ "$(basename "$img" | cut -d. -f1)" = "$selected_image" ]]; then
        selected_image_path="$img"
        break
    fi
done

# Apply if valid selection
if [ -n "$selected_image_path" ]; then
  ln -sf "$selected_image_path" "$image_dir/sky.png"

  if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    . ~/.config/scripts/wallpaper_switch.sh
  else
    i3-msg restart
  fi

  notify-send -a "Wallpaper selector" "(∩\`ω´)⊃)) done ; " -i "$image_dir/sky.png"
  . ~/.config/scripts/apply_wal.sh
fi


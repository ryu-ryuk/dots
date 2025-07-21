#!/bin/bash

# check if an image path was provided
if [ -z "$1" ]; then exit 1; fi

IMAGE_PATH="$1"
# find your monitor name with `hyprctl monitors`
MONITOR="eDP-1"
ext="${IMAGE_PATH##*.}"

# --- LOGIC FOR STATIC IMAGES (PNG, JPG) ---
if [[ "${ext,,}" == "png" || "${ext,,}" == "jpg" || "${ext,,}" == "jpeg" ]]; then
    # stop the gif player if it's running
    pkill mpvpaper

    # ensure hyprpaper is running and responsive
    if ! pgrep -x hyprpaper > /dev/null; then
        hyprpaper &
        # wait until hyprpaper is ready to accept commands
        attempts=0
        while ! hyprctl hyprpaper listactive > /dev/null 2>&1; do
            sleep 0.2
            ((attempts++))
            if [ "$attempts" -ge 15 ]; then # max wait 3 seconds
                notify-send "Wallpaper Error" "hyprpaper failed to start"
                exit 1
            fi
        done
    fi
    
    # set the wallpaper using hyprpaper
    hyprctl hyprpaper preload "$IMAGE_PATH"
    hyprctl hyprpaper wallpaper "$MONITOR,$IMAGE_PATH"

# --- LOGIC FOR GIFS ---
elif [[ "${ext,,}" == "gif" ]]; then
    # stop the static wallpaper daemon
    pkill hyprpaper

    # convert gif to mp4 for performance
    cache_dir="$HOME/.cache/wallpapers"
    mkdir -p "$cache_dir"
    vid_name="$(echo -n "$IMAGE_PATH" | md5sum | awk '{print $1}').mp4"
    vid_path="$cache_dir/$vid_name"
    if [ ! -f "$vid_path" ]; then
        notify-send "Wallpaper" "First time setup: converting GIF to video..."
        ffmpeg -y -i "$IMAGE_PATH" -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" -c:v libx264 -tune animation -pix_fmt yuv420p -an "$vid_path" >/dev/null 2>&1
    fi

    # play the converted video with mpvpaper
    pkill mpvpaper # kill any old instance
    sleep 0.1
    mpvpaper -o "--loop --no-audio --hwdec=auto --no-config" "$MONITOR" "$vid_path" &
fi

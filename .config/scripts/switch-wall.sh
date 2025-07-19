#!/usr/bin/env bash

read scale screenx screeny screenh < <(
    hyprctl monitors -j | jq -r '.[] | select(.focused) | "\(.scale) \(.x|tonumber|floor) \(.y|tonumber|floor) \(.height|tonumber|floor)"'
)

scale=${scale:-1.0}
cursorx=$(hyprctl cursorpos -j | jq -r '.x // 960')
cursory=$(hyprctl cursorpos -j | jq -r '.y // 540')
cursorx=$(printf "%.0f" "$cursorx")
cursory=$(printf "%.0f" "$cursory")

if [[ -z "$cursorx" || -z "$cursory" ]]; then
    cursorx=$((screenx + 960))
    cursory=$((screeny + 540))
fi

relx=$(printf "%.0f" $(bc <<< "($cursorx - $screenx) * $scale"))
rely=$(printf "%.0f" $(bc <<< "($cursory - $screeny) * $scale"))
rely_inv=$(( screenh - rely ))

imgpath="$1"
if [[ -z "$imgpath" || ! -f "$imgpath" ]]; then
    echo "Valid wallpaper not provided"
    exit 1
fi

ext="${imgpath##*.}"
ext="${ext,,}"

# 🎞️ handle gifs with mpvpaper
if [[ "$ext" == "gif" ]]; then
    pkill swww-daemon 2>/dev/null || true
    pkill mpvpaper 2>/dev/null || true
    sleep 0.2
    mpvpaper -o "--loop --no-audio --untimed --no-config" '*' "$imgpath" &
    disown
    exit 0
fi

# 🖼️ handle static wallpapers with swww
pkill mpvpaper 2>/dev/null || true

pgrep -x swww-daemon >/dev/null || swww-daemon &
for i in {1..10}; do
    swww query >/dev/null 2>&1 && break
    sleep 0.2
done

swww img "$imgpath" \
    --transition-type grow \
    --transition-fps 120 \
    --transition-duration 1 \
    --transition-step 100 \
    --transition-angle 30 \
    --transition-pos "$relx,$rely_inv"


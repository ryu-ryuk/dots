#!/usr/bin/env bash


# Get focused monitor scale and position
read scale screenx screeny screenh < <(
    hyprctl monitors -j | jq -r '.[] | select(.focused) | "\(.scale) \(.x) \(.y) \(.height)"'
)

# Get cursor position
cursorx=$(hyprctl cursorpos -j | jq -r '.x // 960')
cursory=$(hyprctl cursorpos -j | jq -r '.y // 540')

# Calculate relative cursor position for transition
relx=$(bc <<< "scale=0; ($cursorx - $screenx) * $scale / 1")
rely=$(bc <<< "scale=0; ($cursory - $screeny) * $scale / 1")
rely_inv=$((screenh - rely))

# Set wallpaper
imgpath="$1"
if [[ -z "$imgpath" || ! -f "$imgpath" ]]; then
    echo "Valid wallpaper not provided"
    exit 1
fi

swww img "$imgpath" \
    --transition-type grow \
    --transition-fps 120 \
    --transition-duration 1 \
    --transition-step 100 \
    --transition-angle 30 \
    --transition-pos "$relx,$rely_inv"

#!/usr/bin/env bash

# Get focused monitor scale and position (rounded to int)
read scale screenx screeny screenh < <(
    hyprctl monitors -j | jq -r '.[] | select(.focused) | "\(.scale) \(.x|tonumber|floor) \(.y|tonumber|floor) \(.height|tonumber|floor)"'
)

# Fallback scale if not set
scale=${scale:-1.0}

# Get cursor pos
cursorx=$(hyprctl cursorpos -j | jq -r '.x // 960')
cursory=$(hyprctl cursorpos -j | jq -r '.y // 540')

# Force integers
cursorx=$(printf "%.0f" "$cursorx")
cursory=$(printf "%.0f" "$cursory")

# Fallback if cursor values are missing
if [[ -z "$cursorx" || -z "$cursory" ]]; then
    cursorx=$((screenx + 960))
    cursory=$((screeny + 540))
fi

# Calculate relative position (rounded)
relx=$(printf "%.0f" $(bc <<< "($cursorx - $screenx) * $scale"))
rely=$(printf "%.0f" $(bc <<< "($cursory - $screeny) * $scale"))
rely_inv=$(( screenh - rely ))

# Get image path
imgpath="$1"
if [[ -z "$imgpath" || ! -f "$imgpath" ]]; then
    echo "Valid wallpaper not provided"
    exit 1
fi

# ensure swww-daemon is running
pgrep -x swww-daemon >/dev/null || swww-daemon 
# Wait for swww socket to be ready
for i in {1..10}; do
    swww query >/dev/null 2>&1 && break
    sleep 0.2
done

# Set wallpaper with transition
swww img "$imgpath" \
    --transition-type grow \
    --transition-fps 120 \
    --transition-duration 1 \
    --transition-step 100 \
    --transition-angle 30 \
    --transition-pos "$relx,$rely_inv"


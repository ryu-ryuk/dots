#!/bin/env bash

ICON_PATH="$HOME/.config/scripts/icons"
VIDEO_DIR="$HOME/Videos"
TIMESTAMP=$(date +%m-%d-%Y-%H:%M:%S)

mkdir -p "$VIDEO_DIR"

if pgrep -x "wf-recorder" > /dev/null; then
    pkill -INT -x wf-recorder
    notify-send -i "$ICON_PATH/recording.png" -t 1000 "Finished Recording"
    exit 0
fi

for i in 3 2 1; do
    notify-send -i "$ICON_PATH/recording.png" -t 1000 "Recording in:" "<span color='#90a4f4' font='26px'><i><b>$i</b></i></span>"
    sleep 1
done

wf-recorder -f "$VIDEO_DIR/$TIMESTAMP.mp4"

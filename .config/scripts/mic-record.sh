#!/bin/bash

ICON_PATH="$HOME/.config/scripts/icons"
VIDEO_DIR="$HOME/Videos/records/"
TIMESTAMP=$(date +%m-%d-%Y-%H:%M:%S)
PID_FILE="/tmp/wf_recording.pid"
AUDIO_PIPE="/tmp/audio_pipe.wav"

mkdir -p "$VIDEO_DIR"

# Stop recording if already running
if [[ -f "$PID_FILE" ]]; then
    kill -INT "$(cat "$PID_FILE")" 2>/dev/null
    rm -f "$PID_FILE" "$AUDIO_PIPE"
    notify-send -i "$ICON_PATH/recording.png" "✅ Recording stopped"
    exit 0
fi

# Countdown before start
for i in 3 2 1; do
    notify-send -i "$ICON_PATH/recording.png" "Recording starts in..." "$i"
    sleep 1
done

# Create named pipe for audio
mkfifo "$AUDIO_PIPE"

# Start recording audio with pw-cat (PipeWire native)
pw-cat --record --channels=2 --rate=44100 --format=s16le > "$AUDIO_PIPE" &

# Start wf-recorder (video) + pipe audio
wf-recorder -f "$VIDEO_DIR/$TIMESTAMP.mp4" --audio="$AUDIO_PIPE" &

# Save wf-recorder PID for stopping later
echo $! > "$PID_FILE"

notify-send -i "$ICON_PATH/recording.png" "🔴 Recording started"


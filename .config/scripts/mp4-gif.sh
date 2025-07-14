#!/bin/bash

# usage: ./mp4-gif.sh input.mp4

if [ $# -ne 1 ]; then
  echo "Usage: $0 input.mp4"
  exit 1
fi

INPUT="$1"
BASENAME=$(basename "$INPUT" .mp4)
PALETTE="${BASENAME}_palette.png"
GIF="${BASENAME}.gif"

# generate palette
ffmpeg -i "$INPUT" -vf "fps=15,scale=800:-1:flags=lanczos,palettegen" -y "$PALETTE"

# create gif using palette
ffmpeg -i "$INPUT" -i "$PALETTE" -filter_complex "fps=15,scale=800:-1:flags=lanczos[x];[x][1:v]paletteuse" -y "$GIF"

# cleanup
rm "$PALETTE"

echo "GIF created: $GIF"


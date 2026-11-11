#!/bin/sh
# Regenerates the synthesised sounds: Yahoo.wav, the cowboy's cry when a player wins an extra life.
#
#   sh tools/sounds/build.sh
#
# Needs only python3. The sound is written to tools/sounds/out, to listen to it and to use it:
#
#   afplay tools/sounds/out/Yahoo.wav
#   cp tools/sounds/out/Yahoo.wav CrazyBrag/sounds/
set -e
D="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$D/out"
python3 "$D/yahoo.py" "$D/out/Yahoo.wav" "$D/out/Yahoo.pgm"
echo "Wrote $D/out/Yahoo.wav"

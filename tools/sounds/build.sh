#!/bin/sh
# Regenerates the synthesised sounds: Yahoo.wav, the cowboy's cry when a player wins an extra life,
# and LoseLife.wav, the breaking glass when a player loses one.
#
#   sh tools/sounds/build.sh
#
# Needs only python3. The sounds are written to tools/sounds/out, to listen to them and to use them:
#
#   afplay tools/sounds/out/Yahoo.wav
#   cp tools/sounds/out/Yahoo.wav tools/sounds/out/LoseLife.wav CrazyBrag/sounds/
#   cp tools/sounds/out/Yahoo.wav tools/sounds/out/LoseLife.wav web/assets/sounds/
set -e
D="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$D/out"
python3 "$D/yahoo.py" "$D/out/Yahoo.wav" "$D/out/Yahoo.pgm"
python3 "$D/glass.py" "$D/out/LoseLife.wav" "$D/out/LoseLife.pgm"
echo "Wrote $D/out/Yahoo.wav and $D/out/LoseLife.wav"

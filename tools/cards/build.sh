#!/bin/sh
# Regenerates the western playing cards: 52 faces and the back, each 691x1056 with transparent corners.
#
#   sh tools/cards/build.sh
#
# cards.py draws the cards as SVG, headless Chrome renders a sheet per suit and ImageMagick
# cuts the sheets into the individual images. Requires Google Chrome and ImageMagick.
# The images are written to tools/cards/out/cards, to use them:
#
#   for f in tools/cards/out/cards/*.png; do b=$(basename "$f" .png); cp "$f" "CrazyBrag/Assets.xcassets/$b.imageset/"; done
set -e
D="$(cd "$(dirname "$0")" && pwd)"
OUT="$D/out"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
W=691; H=1056
mkdir -p "$OUT/cards"
python3 "$D/cards.py" "$OUT"
shot() { # name width height
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
    --default-background-color=00000000 --window-size=$2,$3 \
    --user-data-dir="$OUT/chrome-profile" --screenshot="$OUT/$1.png" "file://$OUT/$1.html" >/dev/null 2>&1
}
for S in H D S C; do
  shot sheet_$S $((W * 7)) $((H * 2))
  i=0
  for R in A 2 3 4 5 6 7 8 9 10 J Q K; do
    magick "$OUT/sheet_$S.png" -crop ${W}x${H}+$(((i % 7) * W))+$(((i / 7) * H)) +repage -strip -define png:exclude-chunks=date,time "$OUT/cards/$R$S.png"
    i=$((i + 1))
  done
done
shot sheet_back $W $H
magick "$OUT/sheet_back.png" -strip -define png:exclude-chunks=date,time "$OUT/cards/CardBack.png"
echo "Wrote $OUT/cards"

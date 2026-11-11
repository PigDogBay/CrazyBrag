#!/bin/sh
# Regenerates the Looky Looky action button images (ActionLooky, ActionStash, ActionChange), each 256x256.
#
#   sh tools/icons/build.sh
#
# icons.py draws them as SVG, headless Chrome renders the sheet and ImageMagick cuts it up.
# Requires Google Chrome and ImageMagick. The images are written to tools/icons/out, to use them:
#
#   for f in tools/icons/out/Action*.png; do b=$(basename "$f" .png); cp "$f" "CrazyBrag/Assets.xcassets/$b.imageset/"; done
set -e
D="$(cd "$(dirname "$0")" && pwd)"
OUT="$D/out"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
S=256
mkdir -p "$OUT"
NAMES=$(python3 "$D/icons.py" "$OUT")
N=$(echo $NAMES | wc -w)
"$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
  --default-background-color=00000000 --window-size=$((S * N)),$S \
  --user-data-dir="$OUT/chrome-profile" --screenshot="$OUT/sheet.png" "file://$OUT/sheet.html" >/dev/null 2>&1
i=0
for NAME in $NAMES; do
  magick "$OUT/sheet.png" -crop ${S}x${S}+$((i * S))+0 +repage -strip -define png:exclude-chunks=date,time "$OUT/$NAME.png"
  i=$((i + 1))
done
echo "Wrote $OUT"

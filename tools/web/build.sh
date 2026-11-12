#!/bin/sh
# Builds the web game's assets (web/assets) from the iOS game's: the card images, background and
# action icons as WebP, the sounds, and the font.
#
#   sh tools/web/build.sh
#
# Requires ImageMagick with WebP support, and afconvert (part of macOS) for the sounds.
# Run it again after changing an image in Assets.xcassets or a sound in CrazyBrag/sounds.
set -e
D="$(cd "$(dirname "$0")/../.." && pwd)"
SRC="$D/CrazyBrag/Assets.xcassets"
OUT="$D/web/assets"
rm -rf "$OUT"
mkdir -p "$OUT/cards" "$OUT/sounds"

# Card faces are 691x1056, far bigger than they are ever drawn in a browser, so they are halved.
# The marked backs are already that size.
for set in "$SRC"/*.imageset; do
  name="$(basename "$set" .imageset)"
  case "$name" in
    westerntown|treestump|Action*) continue ;;
  esac
  magick "$set/$name.png" -resize 346x528 -quality 86 -define webp:method=6 "$OUT/cards/$name.webp"
done
for name in ActionLooky ActionStash ActionChange; do
  magick "$SRC/$name.imageset/$name.png" -resize 128x128 -quality 90 -define webp:method=6 "$OUT/$name.webp"
done
cp "$SRC/westerntown.imageset/westerntown.jpg" "$OUT/westerntown.jpg"
cp "$D/CrazyBrag/Quentincaps-owxKz.ttf" "$OUT/QuentinCaps.ttf"

# Short sounds are kept as they are, the long ones are compressed
S="$D/CrazyBrag/sounds"
cp "$S/card.wav" "$S/LoseLife.wav" "$S/Yahoo.wav" "$S/ricochet.mp3" "$OUT/sounds/"
afconvert -f m4af -d aac -b 96000 "$S/sad_whistle.wav" "$OUT/sounds/sad_whistle.m4a"
afconvert -f m4af -d aac -b 128000 "$S/honky-tonk.wav" "$OUT/sounds/honky-tonk.m4a"
du -sh "$OUT"
echo "Wrote $OUT"

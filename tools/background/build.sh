#!/bin/sh
# Regenerates the western town background used by the game.
#
#   sh tools/background/build.sh
#
# town.py draws the street scene in greys as an HTML/SVG page, headless Chrome
# renders it to a PNG, and ImageMagick gives it the old-photograph treatment.
# Requires Google Chrome and ImageMagick (brew install imagemagick).
# The result is written to tools/background/out/westerntown.jpg, to use it:
#
#   cp tools/background/out/westerntown.jpg CrazyBrag/Assets.xcassets/westerntown.imageset/
set -e
D="$(cd "$(dirname "$0")" && pwd)"
OUT="$D/out"
FONT="$D/../../CrazyBrag/Quentincaps-owxKz.ttf"
FONT="$(cd "$(dirname "$FONT")" && pwd)/$(basename "$FONT")"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
mkdir -p "$OUT"
python3 "$D/town.py" "$FONT" "$OUT/town.html"
"$CHROME" --headless=new --disable-gpu --hide-scrollbars \
  --force-device-scale-factor=1 --window-size=2048,1536 --allow-file-access-from-files \
  --user-data-dir="$OUT/chrome-profile" --screenshot="$OUT/raw.png" "file://$OUT/town.html" >/dev/null 2>&1
# soft focus, lifted blacks, grain, vignette, then a yellow-sepia duotone
magick "$OUT/raw.png" -colorspace Gray \
  \( +clone -blur 0x14 \) -compose Screen -define compose:args=10 -composite \
  -blur 0x1.1 -level 0%,100%,1.08 \
  \( -size 2048x1536 xc:gray50 -seed 7 -attenuate 0.9 +noise Gaussian -colorspace Gray -blur 0x0.6 \) -compose Overlay -define compose:args=100 -composite \
  \( -size 96x72 xc:gray50 -seed 3 +noise Gaussian -colorspace Gray -resize '2048x1536!' -blur 0x30 -level 30%,70% \) -compose Overlay -define compose:args=100 -composite \
  \( -size 2048x1536 xc:none -stroke 'rgba(255,255,255,0.30)' -fill 'rgba(255,255,255,0.30)' -strokewidth 1 -draw "line 966,886 972,1709 line 993,462 996,1232 line 428,189 429,963 line 1329,628 1324,1068 line 954,310 949,705 line 1143,829 1137,1728 line 1259,405 1263,1118 line 1553,630 1556,1041 line 70,851 65,1642 circle 243,73 244,73 circle 990,1228 991,1228 circle 1900,668 1902,668 circle 800,1063 801,1063 circle 1204,1023 1205,1023 circle 348,936 351,936 circle 1139,833 1141,833 circle 340,1449 341,1449 circle 1291,470 1293,470 circle 1183,60 1184,60 circle 442,820 443,820 circle 1191,791 1192,791 circle 69,1402 70,1402 circle 874,429 875,429 circle 1925,768 1928,768 circle 1627,859 1628,859 circle 813,1382 814,1382 circle 1379,178 1380,178 circle 1362,31 1364,31 circle 483,275 484,275 circle 413,22 414,22 circle 1904,997 1905,997 circle 771,916 773,916 circle 781,1498 782,1498 circle 1717,1318 1719,1318 circle 477,808 479,808 circle 871,0 872,0 circle 1245,40 1246,40 circle 767,807 769,807 circle 410,86 411,86 circle 873,904 874,904 circle 39,1249 40,1249 circle 1213,790 1214,790 circle 304,184 305,184 circle 995,31 997,31 circle 1510,761 1512,761 circle 1856,260 1858,260 circle 1981,1176 1982,1176 circle 1581,374 1584,374 circle 631,636 632,636 circle 1021,1485 1022,1485 circle 649,1514 652,1514 circle 805,1406 807,1406 circle 1976,1236 1977,1236 circle 1726,97 1727,97 circle 446,79 448,79 circle 1045,488 1048,488 circle 1604,526 1606,526 circle 2011,600 2013,600 circle 718,1475 719,1475 circle 517,467 519,467 circle 303,573 304,573 circle 835,1533 836,1533 circle 283,551 285,551 circle 1825,510 1826,510 circle 190,360 191,360 circle 1510,1087 1512,1087 circle 538,188 539,188 circle 566,922 567,922 circle 574,1208 575,1208 circle 73,972 74,972 circle 1277,68 1278,68 circle 306,987 307,987 circle 1274,653 1275,653 circle 296,154 298,154 circle 1506,1509 1507,1509 circle 530,699 531,699 circle 347,1403 349,1403 circle 318,854 319,854 circle 2047,1173 2048,1173" -blur 0x0.5 \) -compose Over -composite \
  \( -size 2048x1536 radial-gradient:white-gray45 -gravity center -resize 130% -extent 2048x1536 \) -compose Multiply -composite \
  +level-colors '#3d2a0f','#f5e3ad' -quality 88 "$OUT/westerntown.jpg"
# the iPhone shows the bottom 2048x945 of the image, the iPad shows all of it
magick "$OUT/westerntown.jpg" -gravity South -crop 2048x945+0+0 +repage "$OUT/preview_iphone.jpg"
echo "Wrote $OUT/westerntown.jpg"

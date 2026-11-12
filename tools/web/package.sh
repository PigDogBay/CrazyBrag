#!/bin/sh
# Packs the web game into a zip to upload to itch.io as an HTML game (index.html is at the top of the zip).
#
#   sh tools/web/package.sh
#
# The zip holds what the browser needs: index.html, js and assets. The tests and package.json are left out.
# It is written to tools/web/out/crazybrag-web-<version>.zip, the version is that of the iOS app.
# The tests are run first, and if an image or sound of the iOS game has changed run tools/web/build.sh before this.
set -e
D="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="$D/tools/web/out"
VERSION="$(sed -n 's/.*MARKETING_VERSION = \([0-9.]*\);.*/\1/p' "$D/CrazyBrag.xcodeproj/project.pbxproj" | sort -r | head -1)"
ZIP="$OUT/crazybrag-web-$VERSION.zip"
(cd "$D/web" && node --test >/dev/null) || { echo "The tests fail, not packing"; exit 1; }
mkdir -p "$OUT"
rm -f "$ZIP"
(cd "$D/web" && zip -q -r -X "$ZIP" index.html js assets -x '*.DS_Store')
echo "Wrote $ZIP"
unzip -l "$ZIP" | tail -1
du -h "$ZIP" | cut -f1

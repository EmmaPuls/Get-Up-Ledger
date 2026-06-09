#!/usr/bin/env bash
#
# build-dmg.sh — archive the app, pause for manual validation, then build an
# (unsigned) DMG with create-dmg.
#
# Flow:
#   1. Archive "Get Up App" (Release, signed with the development team).
#   2. Open the archive in Xcode Organizer and wait for you to Validate it.
#   3. Once you confirm, package the archived .app into a .dmg via create-dmg.
#
# The DMG itself is NOT code-signed (no Developer ID cert). The .app inside
# keeps whatever signature the archive produced.
#
# Overridable via env: CONFIG, DEVELOPMENT_TEAM, BUILD_DIR.
# Requires: Xcode command line tools, create-dmg (brew install create-dmg).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PROJECT="Get Up App.xcodeproj"
SCHEME="Get Up App"
APP_NAME="Get Up Ledger"
CONFIG="${CONFIG:-Release}"
TEAM="${DEVELOPMENT_TEAM:-4JL9AZ65QR}"
BUILD_DIR="${BUILD_DIR:-$ROOT/build}"

command -v create-dmg >/dev/null 2>&1 || {
  echo "error: create-dmg not found. Install with: brew install create-dmg" >&2
  exit 1
}

VERSION="$(grep -E '^MARKETING_VERSION' Version.xcconfig | sed 's/.*=[[:space:]]*//')"
[ -n "$VERSION" ] || { echo "error: could not read MARKETING_VERSION from Version.xcconfig" >&2; exit 1; }

ARCHIVE="$BUILD_DIR/${APP_NAME}-${VERSION}.xcarchive"
DMG="$BUILD_DIR/${APP_NAME}-${VERSION}.dmg"

mkdir -p "$BUILD_DIR"

# 1. Archive ------------------------------------------------------------------
echo "==> Archiving ${APP_NAME} ${VERSION} (${CONFIG}, team ${TEAM})"
rm -rf "$ARCHIVE"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -destination 'generic/platform=macOS' \
  -archivePath "$ARCHIVE" \
  DEVELOPMENT_TEAM="$TEAM" \
  archive

# 2. Validate (manual) --------------------------------------------------------
echo
echo "==> Archive created:"
echo "    $ARCHIVE"
echo "    file://$ARCHIVE"
echo
echo "Opening the archive in Xcode Organizer..."
open "$ARCHIVE" || true
echo
echo "Validate it now: in Organizer select the archive, click"
echo "\"Distribute App\" → choose your method → \"Validate\"."
echo
read -r -p "Type 'validated' once validation has passed (anything else aborts): " CONFIRM
if [ "$CONFIRM" != "validated" ]; then
  echo "Aborted — DMG not built." >&2
  exit 1
fi

# 3. Build the DMG ------------------------------------------------------------
APP="$ARCHIVE/Products/Applications/${APP_NAME}.app"
[ -d "$APP" ] || { echo "error: app not found in archive: $APP" >&2; exit 1; }

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
cp -R "$APP" "$STAGE/"

echo
echo "==> Building DMG"
rm -f "$DMG"

# create-dmg can exit non-zero on a benign Finder/AppleScript hiccup, so don't
# let set -e abort — verify the DMG exists afterwards instead.
set +e
create-dmg \
  --volname "${APP_NAME} ${VERSION}" \
  --window-pos 200 120 \
  --window-size 660 400 \
  --icon-size 100 \
  --icon "${APP_NAME}.app" 165 200 \
  --app-drop-link 495 200 \
  --no-internet-enable \
  "$DMG" "$STAGE"
RC=$?
set -e

if [ ! -f "$DMG" ]; then
  echo "error: create-dmg failed (exit $RC) — no DMG produced." >&2
  exit "$RC"
fi

echo
echo "==> Done:"
echo "    $DMG"
echo "    file://$DMG"

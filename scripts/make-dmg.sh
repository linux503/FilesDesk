#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <FilesDesk.app> <output.dmg>" >&2
  exit 1
fi

APP="$1"
DMG="$2"
VOLNAME="${3:-FilesDesk}"

if [[ ! -d "$APP" ]]; then
  echo "Missing app bundle: $APP" >&2
  exit 1
fi

STAGE="$(mktemp -d /tmp/filesdesk-dmg.XXXXXX)"
trap 'rm -rf "$STAGE"' EXIT

ditto "$APP" "$STAGE/FilesDesk.app"
ln -s /Applications "$STAGE/Applications"

mkdir -p "$(dirname "$DMG")"
rm -f "$DMG"

hdiutil create \
  -volname "$VOLNAME" \
  -srcfolder "$STAGE" \
  -ov \
  -format UDZO \
  -fs HFS+ \
  "$DMG" >/dev/null

echo "Created $DMG"

#!/usr/bin/env bash
set -euo pipefail

# Build → Test → Tag → Release → website sync
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <marketing-version>   e.g. $0 1.0.1" >&2
  exit 1
fi

VERSION="$1"
TAG="v$VERSION"
KEY_FILE="${SPARKLE_KEY_FILE:-$ROOT/sparkle/eddsa-private.key}"
IDENTITY="${CODE_SIGN_IDENTITY:--}"

if [[ ! -f "$KEY_FILE" ]]; then
  echo "Missing Sparkle private key at $KEY_FILE" >&2
  exit 1
fi

python3 "$ROOT/scripts/set-version.py" "$VERSION" --bump-build
IFS=' ()' read -r MARKETING BUILD < <(python3 "$ROOT/scripts/set-version.py")
BUILD="${BUILD:-1}"

echo "==> Test"
xcodebuild test \
  -project FilesDesk.xcodeproj \
  -scheme FilesDesk \
  -destination "platform=macOS" \
  -configuration Debug \
  CODE_SIGN_IDENTITY="$IDENTITY"

echo "==> Build (Universal: arm64 + x86_64)"
rm -rf "$ROOT/build/Release"
xcodebuild build \
  -project FilesDesk.xcodeproj \
  -scheme FilesDesk \
  -destination "generic/platform=macOS" \
  -configuration Release \
  -derivedDataPath "$ROOT/build/DerivedData" \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO \
  CODE_SIGN_IDENTITY="$IDENTITY"

APP="$ROOT/build/DerivedData/Build/Products/Release/FilesDesk.app"
BIN="$APP/Contents/MacOS/FilesDesk"
ARCHS_FOUND="$(lipo -archs "$BIN")"
echo "Architectures: $ARCHS_FOUND"
echo "$ARCHS_FOUND" | grep -qw arm64
echo "$ARCHS_FOUND" | grep -qw x86_64
DIST="$ROOT/build/dist"
mkdir -p "$DIST"
ZIP="$DIST/FilesDesk-$VERSION.zip"
rm -f "$ZIP"
ditto -c -k --keepParent "$APP" "$ZIP"
LENGTH="$(stat -f%z "$ZIP")"
SIG="$(python3 "$ROOT/scripts/sign-update.py" "$KEY_FILE" "$ZIP")"

echo "==> Tag $TAG"
git add FilesDesk.xcodeproj/project.pbxproj CHANGELOG.md docs
git commit -m "Release $TAG" || true
git tag -a "$TAG" -m "FilesDesk $VERSION"
git push origin HEAD
git push origin "$TAG"

echo "==> GitHub Release"
NOTES="$(awk "/^## $VERSION/{flag=1;next}/^## /{flag=0}flag" CHANGELOG.md | sed '/^$/d')"
gh release create "$TAG" "$ZIP" \
  --title "FilesDesk $VERSION" \
  --notes "${NOTES:-FilesDesk $VERSION}"

URL="$(gh release view "$TAG" --json assets --jq ".assets[] | select(.name==\"FilesDesk-$VERSION.zip\") | .url")"
if [[ -z "$URL" ]]; then
  URL="https://github.com/linux503/FilesDesk/releases/download/$TAG/FilesDesk-$VERSION.zip"
fi

python3 "$ROOT/scripts/update-appcast.py" \
  --tag "$TAG" \
  --marketing "$VERSION" \
  --build "$BUILD" \
  --url "$URL" \
  --signature "$SIG" \
  --length "$LENGTH"

git add docs/appcast.xml
git commit -m "Sync Sparkle feed for $TAG" || true
git push origin HEAD

echo "Released $TAG"
echo "Feed: https://linux503.github.io/FilesDesk/appcast.xml"

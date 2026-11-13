#!/bin/bash
# Build PlantGuard for TrollStore: unsigned .app -> .tipa (Payload/*.app zip).
set -euo pipefail
cd "$(dirname "$0")"

# NOTE: -derivedDataPath requires -scheme, and this project has no shared
# scheme file, so use -target with SYMROOT instead: products land in
# build/Release-iphoneos/.
xcodebuild -project PlantGuard.xcodeproj -target PlantGuard \
  -sdk iphoneos -configuration Release SYMROOT=build \
  CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

APP="build/Release-iphoneos/PlantGuard.app"
test -d "$APP" || { echo "ERROR: $APP not found"; exit 1; }

rm -rf Payload PlantGuard-v1.0.0.tipa
mkdir Payload
cp -R "$APP" Payload/
zip -r -y PlantGuard-v1.0.0.tipa Payload
ls -lh PlantGuard-v1.0.0.tipa

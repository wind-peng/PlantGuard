#!/bin/bash
# Build PlantGuard for TrollStore: unsigned .app -> .tipa (Payload/*.app zip).
set -euo pipefail
cd "$(dirname "$0")"

xcodebuild -project PlantGuard.xcodeproj -target PlantGuard \
  -sdk iphoneos -configuration Release -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

APP="build/Build/Products/Release-iphoneos/PlantGuard.app"
test -d "$APP" || { echo "ERROR: $APP not found"; exit 1; }

rm -rf Payload PlantGuard-v1.0.0.tipa
mkdir Payload
cp -R "$APP" Payload/
zip -r -y PlantGuard-v1.0.0.tipa Payload
ls -lh PlantGuard-v1.0.0.tipa

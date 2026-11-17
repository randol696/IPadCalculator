#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
xcodebuild \
  -project IPadCalculator.xcodeproj \
  -scheme IPadCalculator \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build

rm -rf dist
mkdir -p dist/Payload
cp -R build/Build/Products/Release-iphoneos/IPadCalculator.app dist/Payload/
(cd dist && zip -r ../IPadCalculator.ipa Payload)
echo "Wrote $(pwd)/IPadCalculator.ipa"
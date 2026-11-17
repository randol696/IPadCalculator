# iPad Calculator (iOS 12.5)

A small four-function calculator built with **UIKit** so it can run on an iPad stuck on **iOS 12.5**. SwiftUI and SceneDelegate are not used.

This project lives on Windows, so the `.ipa` cannot be compiled here. Xcode on macOS (or GitHub Actions on a Mac runner) has to produce the IPA. After that, **Sideloadly** on Windows can sign and install it on the iPad.

## What you get

- Large iPad layout, portrait and landscape
- `+ − × ÷`, percent, sign change, decimals, and clear
- Deployment target **iOS 12.0**, device family **iPad**
- Bundle id `com.local.IPadCalculator`

## Install on an iPad running iOS 12.5

1. Get an unsigned IPA (Mac or GitHub Actions below).
2. On Windows, install [Sideloadly](https://sideloadly.io/).
3. Plug in the iPad with a cable, trust the computer, and open Sideloadly.
4. Drop in `IPadCalculator.ipa`, enter a free Apple ID, and start the install.
5. On the iPad go to **Settings → General → Device Management** (or Profiles) and trust that Apple ID.

A free Apple ID install lasts 7 days, then you install again. An Apple Developer Program account lasts a year.

The IPA from CI is **unsigned**. Sideloadly re-signs it. It will not install by tapping the file in Files.

## Build the IPA

### Option A — GitHub Actions (no Mac)

Push this folder to GitHub. The workflow `.github/workflows/build-ipa.yml` builds `IPadCalculator.ipa` and uploads it as an artifact. Download that zip and use Sideloadly.

### Option B — Xcode on a Mac

```bash
cd IPadCalculator
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

mkdir -p dist/Payload
cp -R build/Build/Products/Release-iphoneos/IPadCalculator.app dist/Payload/
(cd dist && zip -r ../IPadCalculator.ipa Payload)
```

To run in the iPad simulator on a Mac, open `IPadCalculator.xcodeproj` and press Run with an iPad simulator selected.

Xcode 10.2 through Xcode 15 can target iOS 12. Newer Xcode may still build this project if the deployment target stays 12.0 and no newer APIs are added.

## Project layout

```
IPadCalculator/
  AppDelegate.swift
  CalculatorEngine.swift
  CalculatorTheme.swift
  CalculatorViewController.swift
  Info.plist
  Assets.xcassets
IPadCalculator.xcodeproj
```

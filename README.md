# Phantom — iOS Setup Guide

Phantom is an iOS app that helps investors track "ghost trades" — investment decisions they considered but didn't execute — and calculates the opportunity cost (Hesitation Tax) of those missed trades.

---

## Prerequisites

- A Mac running **macOS 14 Sonoma or later**
- An Apple ID (free — required to download Xcode)

---

## Step 1: Download Xcode

1. Open the **Mac App Store** on your Mac
2. Search for **"Xcode"**
3. Click **Get** → **Install** (Xcode is ~15 GB — this may take 20–40 minutes)
4. Once installed, open Xcode from your Applications folder
5. On first launch, Xcode will prompt: **"Install additional required components"** — click **Install** and enter your password

> **Minimum version required:** Xcode 16.0 or later (required for Swift 6 and iOS 26 SDK)

---

## Step 2: Download the iOS 26 Simulator

The Phantom app targets **iOS 26**. You need to download this simulator runtime:

1. Open Xcode
2. In the menu bar, go to **Xcode → Settings** (or press `⌘ ,`)
3. Click the **Platforms** tab
4. Look for **iOS 26.x** in the list
   - If it shows a **download icon (↓)** next to it, click it to download (~7 GB)
   - If it's already listed with a checkmark ✓, you're good
5. Wait for the download to complete

**Alternative — download via command line:**
```bash
xcodebuild -downloadPlatform iOS
```

---

## Step 3: Clone the Repository

```bash
git clone https://github.com/rlearned/phantom.git
cd phantom
```

---

## Step 4: Open the Xcode Project

1. In Finder, navigate to the cloned `phantom` folder
2. Open the **`ios`** folder
3. Double-click **`Phantom.xcodeproj`** to open it in Xcode

> ⚠️ Open `Phantom.xcodeproj`, **not** a `.xcworkspace` file (there isn't one — no CocoaPods or SPM workspace required).

---

## Step 5: Select a Simulator

1. In the Xcode toolbar at the top, click the **device selector** (it shows something like "Any iOS Device" by default)
2. Under **iOS Simulators**, select an iPhone model running **iOS 26**, e.g.:
   - `iPhone 16 (iOS 26.0)`
   - `iPhone 16 Pro (iOS 26.0)`
3. If no iOS 26 simulator appears, go back to Step 2

---

## Step 6: Build and Run

1. Press **`⌘ R`** (or click the ▶ Play button in the toolbar)
2. Xcode will compile the project — the first build takes ~1–2 minutes
3. The Phantom app will launch automatically in the iOS Simulator

---

## Troubleshooting

**Build fails with "No such module" error**
- Go to **Product → Clean Build Folder** (`⌘ Shift K`), then rebuild (`⌘ R`)

**Simulator not showing iOS 26**
- Go to **Xcode → Settings → Platforms** and confirm iOS 26 is downloaded (see Step 2)

**"Signing requires a development team" error**
- Go to the project navigator → click **Phantom** (top-level) → **Signing & Capabilities**
- Select your Apple ID under **Team** (a free Apple ID works for simulator builds)

**App crashes immediately on launch**
- Make sure you selected an **iOS 26** simulator — the app may not launch on older iOS versions
- or... simply rebuild...

**Xcode says "Unable to boot device"**
- Go to **Window → Devices and Simulators**, find the stuck simulator, and click **Erase All Content and Settings**

---

## Project Structure

```
phantom/
├── ios/                    # iOS app (Swift / SwiftUI)
│   ├── Core/               # Auth, models, networking
│   ├── Features/           # Feature modules (Dashboard, GhostLogging, etc.)
│   ├── DesignSystem/       # Colors, typography, shared UI components
│   └── Phantom.xcodeproj  # ← Open this in Xcode
├── service/                # Java backend (AWS Lambda)
└── infra/                  # AWS CDK infrastructure
```

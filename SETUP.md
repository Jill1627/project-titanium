# Local Development Setup

## Prerequisites

- **macOS 14+ (Sonoma)** or later
- **Xcode 15.4+** — download from the [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835) or [Apple Developer](https://developer.apple.com/xcode/)
- An Apple ID (free tier is sufficient for simulator testing)

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/Jill1627/project-titanium.git
cd project-titanium

# 2. Open in Xcode
open ProjectTitanium.xcodeproj
```

## Running in the Simulator

### From Xcode UI

1. Open `ProjectTitanium.xcodeproj` in Xcode
2. Select the **ProjectTitanium** scheme in the top toolbar
3. Choose a simulator device (e.g., **iPhone 16** or **iPhone 16 Pro**)
4. Press **Cmd+R** to build and run
5. The app will launch in the iOS Simulator

### From the command line

```bash
# Make sure Xcode is selected as the active developer tools
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# Build the project
xcodebuild -project ProjectTitanium.xcodeproj \
  -scheme ProjectTitanium \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build

# Build and run (launches simulator)
xcodebuild -project ProjectTitanium.xcodeproj \
  -scheme ProjectTitanium \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -resultBundlePath build/result \
  build

# To run after building:
xcrun simctl boot "iPhone 16"
xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/ProjectTitanium.app
xcrun simctl launch booted com.vaultandedge.app
```

## Running Tests

### From Xcode UI

1. Press **Cmd+U** to run all tests
2. Or open the Test Navigator (Cmd+6) and click the play button next to individual test classes

### From the command line

```bash
xcodebuild test \
  -project ProjectTitanium.xcodeproj \
  -scheme ProjectTitanium \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -resultBundlePath build/test-results
```

### Test structure

| File                            | Type        | Coverage                                                            |
| ------------------------------- | ----------- | ------------------------------------------------------------------- |
| `SportTypeTests.swift`          | Unit        | SportType enum: raw values, display names, Codable                  |
| `LandingTypeTests.swift`        | Unit        | LandingType enum: raw values, isClean, Codable                      |
| `ScoringEngineTests.swift`      | Unit        | Skating/gymnastics scoring logic, scale factors, floor-at-zero      |
| `ModelTests.swift`              | Unit        | Athlete, ElementScore, RunThrough, PlannedProgramContent models     |
| `AnalyzerViewModelTests.swift`  | Unit        | AnalyzerViewModel: scoring state, PPC, playback, deductions         |
| `DashboardViewModelTests.swift` | Unit        | DashboardViewModel: filtering, sorting, heatmap, trend data         |
| `IntegrationTests.swift`        | Integration | Cross-component flows: scoring, PPC, dashboard, model relationships |

## Simulator Tips

### Adding test videos to the simulator

The app requires video access from the Photo Library. To add test videos to the simulator:

```bash
# Drag and drop a .mov or .mp4 file onto the simulator window
# OR use the command line:
xcrun simctl addmedia booted /path/to/your/test-video.mov
```

### Testing different sports

1. On first launch, the onboarding screen lets you pick **Figure Skating** or **Gymnastics**
2. To switch sports later, go to the **Settings** tab
3. To reset onboarding, use **Settings > Reset Onboarding**

### Simulating haptics

Haptic feedback (CoreHaptics) does not work in the simulator. To test haptics, run on a physical device with the Taptic Engine.

### Available simulator devices

```bash
# List all available simulators
xcrun simctl list devices available

# Boot a specific simulator
xcrun simctl boot "iPhone 16 Pro"

# Shut down all simulators
xcrun simctl shutdown all
```

## Building for a Physical Device

1. In Xcode, select your physical iPhone as the run destination
2. You may need to trust the developer certificate on the device:
   - Go to **Settings > General > VPN & Device Management** on the iPhone
   - Tap the developer profile and trust it
3. Press **Cmd+R** to build and install

## Project Architecture

```
ProjectTitanium/
├── App/                    # App entry point, tab navigation
├── Models/                 # SwiftData @Model classes
├── Views/
│   ├── Onboarding/         # Sport selection
│   ├── AthleteList/        # Athlete roster + run-through list
│   ├── Analyzer/           # Video player, scoring tray, timeline
│   ├── Dashboard/          # Heatmap, trend chart
│   ├── PPCEditor/          # Planned program content
│   └── Settings/           # Sport toggle, app settings
├── ViewModels/             # AnalyzerViewModel, DashboardViewModel
├── Services/               # ScoringEngine, PhotoLibrary, Haptics
└── Extensions/             # Color theme

ProjectTitaniumTests/       # Unit + integration tests
```

## Troubleshooting

**"No such module 'ProjectTitanium'"** in tests

- Clean build folder: **Product > Clean Build Folder** (Cmd+Shift+K)
- Close and reopen the project

**Simulator not appearing**

- Check Xcode has downloaded the iOS 17 simulator runtime:
  **Xcode > Settings > Platforms** and download iOS 17+

**Photo Library permission not showing**

- The permission dialog appears on first video import attempt
- To reset permissions: **Device > Erase All Content and Settings** in the simulator menu

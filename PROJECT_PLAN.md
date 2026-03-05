# Vault & Edge — Project Plan

## Overview

iOS native app (SwiftUI, iOS 17+) for figure skating and gymnastics coaches to timestamp video elements and apply sport-specific scoring. Video lives in iCloud Shared Albums; only metadata (scores, timestamps, notes) syncs via CloudKit.

PRD: `PRD.md`

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI (iOS 17+) |
| Video | AVFoundation + PhotosKit |
| Local persistence | SwiftData |
| Cloud sync | CloudKit (private DB) |
| Charts | Swift Charts |
| Haptics | CoreHaptics |

---

## Design Tokens

```
Background:   #FFFFFF / #F2F2F7 (system grouped)
Accent Mint:  #00FFCC  (positive scores, stuck landings)
Accent Coral: #FF7F7F  (deductions, falls)
Typography:   SF Pro (system) — Large Title > Title > Body > Caption
Corner radius: 16pt cards, 12pt chips
```

Design tool: **Pencil.dev** — design each screen before implementing.

---

## Screens

| # | Screen | Status |
|---|---|---|
| 1 | Onboarding / Sport Setup | Not started |
| 2 | Athlete List (Home) | Not started |
| 3 | Run-Through List (per athlete) | Not started |
| 4 | Video Analyzer | Not started |
| 5 | Element Detail / Edit | Not started |
| 6 | Consistency Heatmap | Not started |
| 7 | Trend Spline | Not started |
| 8 | PPC Editor | Not started |
| 9 | Settings | Not started |

**Design priority:** Screen 4 (Video Analyzer) first — it is the most complex.

---

## Architecture

```
VaultAndEdge/
├── App/
│   └── VaultAndEdgeApp.swift
├── Models/                        # SwiftData @Model classes
│   ├── SportType.swift            # enum: .skating, .gymnastics
│   ├── LandingType.swift          # enum: .stuck, .hop, .step, .fall
│   ├── ElementScore.swift         # elementCode, timestamp, executionValue, landing, note
│   └── RunThrough.swift           # athleteID, videoLocalIdentifier, date, totalScore, elements
├── Views/
│   ├── Onboarding/
│   ├── AthleteList/
│   ├── Analyzer/
│   │   ├── VideoPlayerView.swift       # AVPlayer, 240fps scrubbing, pinch-zoom
│   │   ├── ScoringTrayView.swift       # GOE slider (-5→+5) OR deduction chips
│   │   ├── LandingButtonsView.swift    # Stuck / Hop / Step / Fall
│   │   └── ElementTimelineView.swift   # Timestamped element list
│   ├── Dashboard/
│   │   ├── ConsistencyHeatmapView.swift
│   │   └── TrendSplineView.swift
│   └── PPCEditor/
├── ViewModels/
│   ├── AnalyzerViewModel.swift         # Scoring logic engine, sync pin logic
│   └── DashboardViewModel.swift
└── Services/
    ├── PhotoLibraryService.swift        # PHAsset / Shared Album access
    ├── CloudKitService.swift            # Metadata sync
    └── HapticsService.swift             # Distinct patterns: stuck vs deduction
```

---

## Scoring Logic

**Skating:** `baseValue + (GOE × scaleFactor)`
- GOE slider: -5 to +5, scale factor varies by element type

**Gymnastics:** `DScore - Σ(deductions)`
- Deduction chips: -0.1, -0.3, -0.5, -1.0

Implement as a `ScoringEngine` protocol with sport-specific conformances.

---

## Key Implementation Notes

- **Video access:** Stream via `PHAsset` + `PHImageManager`; never copy video bytes into app storage. Store only `PHAsset.localIdentifier` in `RunThrough.videoLocalIdentifier`.
- **Sync pin:** "Sync" button captures `player.currentTime()` as `CMTime`, stored as `ElementScore.timestamp: Double` (seconds offset).
- **CloudKit:** SwiftData with CloudKit private database for sync. Video bytes never leave the device/iCloud Photos.
- **Haptics:** `CoreHaptics` — success pattern for Stuck, short taps for deductions/falls.
- **Dashboard heatmap:** Color buckets — Mint if avg execution > 80% of max; Coral if < 50%.

---

## Phases

### Phase 1 — Foundation
- [ ] Xcode project, SwiftData models, sport selection onboarding, PhotosKit permission flow

### Phase 2 — Analyzer (Core)
- [ ] AVPlayer video view with 240fps scrubbing and pinch-zoom
- [ ] Scoring tray (GOE slider / deduction chips, sport-aware)
- [ ] Element timestamping (Sync button → CMTime pin)
- [ ] Landing buttons + haptics

### Phase 3 — Dashboard
- [ ] Consistency heatmap grid
- [ ] Trend spline (Swift Charts)
- [ ] PPC pre-load editor

### Phase 4 — Cloud & Polish
- [ ] CloudKit sync
- [ ] Athlete management and sharing
- [ ] Edge cases, accessibility, App Store prep

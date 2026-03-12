# Vault & Edge — Project Plan

## Overview

iOS native app (SwiftUI, iOS 17+) for figure skating and gymnastics coaches to timestamp video elements and apply sport-specific scoring. Video lives in iCloud Shared Albums; only metadata (scores, timestamps, notes) syncs via CloudKit.

PRD: `PRD.md`

---

## Tech Stack

| Layer             | Technology               |
| ----------------- | ------------------------ |
| UI                | SwiftUI (iOS 17+)        |
| Video             | AVFoundation + PhotosKit |
| Local persistence | SwiftData                |
| Cloud sync        | CloudKit (private DB)    |
| Charts            | Swift Charts             |
| Haptics           | CoreHaptics              |

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

| #   | Screen                           | Status                    |
| --- | -------------------------------- | ------------------------- |
| 1   | Onboarding / Sport Setup         | Done                      |
| 2   | Athlete List (Home)              | Done                      |
| 3   | Run-Through List (per athlete)   | Done                      |
| 3b  | **Runthrough Detail View**       | **To Do** (design ready)  |
| 4   | Video Analyzer                   | Done                      |
| 5   | Element Detail / Edit            | Done (inline in Analyzer) |
| 6   | Consistency Heatmap              | Done                      |
| 7   | Trend Spline                     | Done                      |
| 8   | PPC Editor                       | Done (optional for MVP)   |
| 9   | Settings                         | Done                      |

**Design priority:** Screen 4 (Video Analyzer) first — it is the most complex.

**Screen 3b (Runthrough Detail View):** Summary page showing program name, runthrough date, final score, coach notes, and list of scored elements with timestamps. Design completed in Pencil.dev. Navigates from Runthrough List → Detail → Analyzer.

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
│   ├── RunThrough.swift           # athleteID, programName, videoLocalIdentifier, date, totalScore, elements, coachNote
│   └── PlannedProgramContent.swift # Optional coach-created templates (not required for MVP)
├── Views/
│   ├── Onboarding/
│   ├── AthleteList/
│   │   ├── AthleteListView.swift
│   │   ├── RunThroughListView.swift       # List of runthroughs per athlete
│   │   └── RunThroughDetailView.swift     # **NEW** Summary of single runthrough
│   ├── Analyzer/
│   │   ├── VideoPlayerView.swift          # AVPlayer, 240fps scrubbing, pinch-zoom
│   │   ├── ScoringTrayView.swift          # GOE slider (-5→+5) OR deduction chips
│   │   ├── LandingButtonsView.swift       # Stuck / Hop / Step / Fall
│   │   └── ElementTimelineView.swift      # Timestamped element list
│   ├── Dashboard/
│   │   ├── ConsistencyHeatmapView.swift
│   │   └── TrendSplineView.swift
│   └── PPCEditor/                         # Optional (future enhancement)
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
- **Element entry (MVP):** First runthrough for a program starts blank; subsequent runthroughs auto-copy elements from the latest runthrough of the same `programName`. Coach can edit inline if program layout changes.
- **Navigation flow:** Athlete List → Runthrough List → **Runthrough Detail (new)** → Analyzer (for live scoring).

---

## Phases

### Phase 1 — Foundation

- [x] Xcode project, SwiftData models, sport selection onboarding, PhotosKit permission flow

### Phase 2 — Analyzer (Core)

- [x] AVPlayer video view with 240fps scrubbing and pinch-zoom
- [x] Scoring tray (GOE slider / deduction chips, sport-aware)
- [x] Element timestamping (Sync button → CMTime pin)
- [x] Landing buttons + haptics

### Phase 3 — Dashboard & Runthrough Detail

- [x] Consistency heatmap grid
- [x] Trend spline (Swift Charts)
- [ ] **Runthrough Detail View** (design ready, needs implementation)
- [x] PPC editor (optional for MVP)

### Phase 4 — Smart Element Copy & Polish

- [ ] Add `programName` and `coachNote` fields to `RunThrough` model
- [ ] Implement auto-copy from latest runthrough logic
- [ ] Update navigation: List → Detail → Analyzer
- [ ] CloudKit sync
- [x] Athlete management and sharing
- [ ] Edge cases, accessibility, App Store prep

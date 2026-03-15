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

| #   | Screen                         | Status | Notes                                    |
| --- | ------------------------------ | ------ | ---------------------------------------- |
| 1   | Onboarding / Sport Setup       | ✅ Done | Sport selection on first launch          |
| 2   | Athlete List (Home)            | ✅ Done | List of athletes by sport                |
| 3   | Run-Through List (per athlete) | ✅ Done | All runthroughs for selected athlete     |
| 3b  | Runthrough Detail View         | ✅ Done | Summary with element list, tap to edit   |
| 4   | Video Analyzer                 | ✅ Done | Live scoring with ISU element picker     |
| 5   | Element Scoring Sheet          | ✅ Done | Edit existing elements (from detail view)|
| 6   | Consistency Heatmap            | ✅ Done | Dashboard view                           |
| 7   | Trend Spline                   | ✅ Done | Dashboard view                           |
| 8   | PPC Editor                     | ✅ Done | Optional, not in main flow               |
| 9   | Settings                       | ✅ Done | App preferences                          |

**Navigation Flow:**
- Athlete List → Runthrough List → Runthrough Detail → Analyzer (live scoring)
- Runthrough Detail: Tap element → Element Scoring Sheet (edit mode)
- Analyzer: Sync button → Creates new timestamped element

---

## Architecture

```
VaultAndEdge/
├── App/
│   └── VaultAndEdgeApp.swift
├── Models/                              # SwiftData @Model classes
│   ├── SportType.swift                  # enum: .skating, .gymnastics
│   ├── LandingType.swift                # enum: .stuck, .hop, .step, .fall
│   ├── RotationCall.swift               # enum: .clean, .underRotated, .quarter, .downgraded
│   ├── EdgeCall.swift                   # enum: .correct, .attention, .wrongEdge
│   ├── FigureSkatingElement.swift       # ISU element registry (44 elements)
│   ├── ElementScore.swift               # elementCode, level, timestamp, GOE, technical calls
│   ├── RunThrough.swift                 # athleteID, programName, videoLocalIdentifier, date, elements, coachNote
│   ├── Athlete.swift                    # name, sport, runthroughs
│   └── PlannedProgramContent.swift      # Optional coach-created templates
├── Views/
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   ├── AthleteList/
│   │   ├── AthleteListView.swift
│   │   ├── RunThroughListView.swift       # List of runthroughs per athlete
│   │   ├── RunThroughDetailView.swift     # Summary view of single runthrough
│   │   ├── ElementScoringSheet.swift      # Edit existing elements (full scoring UI)
│   │   └── ElementPickerSheet.swift       # ISU element selection modal (shared)
│   ├── Analyzer/
│   │   ├── AnalyzerView.swift             # Main analyzer container
│   │   ├── VideoPlayerView.swift          # AVPlayer, 240fps scrubbing, pinch-zoom
│   │   ├── ScoringTrayView.swift          # Create new elements (GOE, technical calls, element picker)
│   │   ├── LandingButtonsView.swift       # Stuck / Hop / Step / Fall
│   │   └── ElementTimelineView.swift      # Timestamped element list
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   ├── ConsistencyHeatmapView.swift
│   │   └── TrendSplineView.swift
│   ├── PPCEditor/
│   │   └── PPCEditorView.swift            # Optional (future enhancement)
│   └── Settings/
│       └── SettingsView.swift
├── ViewModels/
│   ├── AnalyzerViewModel.swift            # Scoring logic, sync pin logic, element registry
│   └── DashboardViewModel.swift
└── Services/
    ├── ScoringEngine.swift                # ISU-compliant calculation engine
    ├── SeedDataService.swift              # Mock data for testing
    ├── PhotoLibraryService.swift          # PHAsset / Shared Album access
    └── HapticsService.swift               # Distinct patterns: stuck vs deduction
```

**Note on Element Scoring UI:**
- `ScoringTrayView` (Analyzer): Creates NEW elements during live video analysis
- `ElementScoringSheet` (AthleteList): Edits EXISTING elements from detail view
- Both share `ElementPickerSheet` for ISU element selection
- Similar UI but different purposes (create vs edit)

---

## Scoring Logic

**Figure Skating (ISU 2025-2026):**
- Element selection from official ISU registry (44 elements)
- Base values: Fixed for jumps, level-based (LB, L1-L4) for spins/sequences
- GOE: -5 to +5, calculated at 10% per level (e.g., +3 GOE = +30% of base)
- Technical calls with alternate base values:
  - Under-rotation (`<`): Uses alternate base value
  - Downgrade (`<<`): Uses lower revolution element
  - Edge error (`e`): Uses alternate base value
  - Combined (`< + e`): Uses combined alternate value
  - Quarter (`q`): Keeps base, GOE capped at +2
  - Edge attention (`!`): Keeps base, negative GOE
- Modifiers: Repeat penalty (70%), second-half bonus (1.1x)
- Fall deduction: -1.0 from final score

**Formula:** `adjustedBase + GOE adjustment - fall penalty`

**Gymnastics:** `DScore - Σ(deductions)`
- Deduction chips: -0.1, -0.3, -0.5, -1.0

Implemented as `ScoringEngine` protocol with `SkatingScoring` and `GymnasticsScoring` conformances.

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

### Phase 1 — Foundation ✅

- [x] Xcode project, SwiftData models, sport selection onboarding, PhotosKit permission flow
- [x] Athlete model with sport type
- [x] RunThrough model with video reference

### Phase 2 — Analyzer (Core) ✅

- [x] AVPlayer video view with 240fps scrubbing and pinch-zoom
- [x] Scoring tray (GOE slider / deduction chips, sport-aware)
- [x] Element timestamping (Sync button → CMTime pin)
- [x] Landing buttons + haptics
- [x] Element timeline view

### Phase 3 — Dashboard & Runthrough Detail ✅

- [x] Consistency heatmap grid
- [x] Trend spline (Swift Charts)
- [x] Runthrough Detail View (summary with element list)
- [x] PPC editor (optional for MVP)
- [x] Settings view

### Phase 4 — ISU-Compliant Scoring ✅

- [x] ISU 2025-2026 element registry (44 elements)
- [x] Element picker sheet with search and category filters
- [x] GOE calculation (10% per level)
- [x] Technical calls (rotation, edge)
- [x] Alternate base values (<, e, < + e)
- [x] Downgrade handling (<<)
- [x] Level selection for spins/sequences
- [x] Element scoring sheet for editing existing elements
- [x] Updated seed data with ISU-compliant scoring

### Phase 5 — Polish & Cloud Sync (Next)

- [ ] CloudKit sync for metadata
- [ ] Auto-copy elements from latest runthrough
- [ ] Enhanced video thumbnail in detail view
- [ ] Edge cases, accessibility
- [ ] App Store prep

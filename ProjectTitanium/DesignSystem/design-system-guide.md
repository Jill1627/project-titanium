# Titanium — Design System
> Single source of truth for Claude Code / Pencil.dev iOS screen generation.
> Never hardcode hex values in components — always use token names.
> Never reference sport.* tokens directly — always go through active ThemeManager.

---

## App Identity
- **Name:** Titanium
- **Platform:** iOS (iPhone, portrait)
- **Grid:** 8pt base unit — all spacing is multiples of 8
- **Screen width:** 390pt (iPhone 15 base). Safe area: 16pt horizontal margins.
- **Audience:** Gymnasts and figure skaters
- **Mood:** Indie warmth + athletic precision. Trusted coach meets personal sketchbook.
- **Dark mode:** Full support — every token resolves correctly in light and dark

---

## Color Tokens

### Semantic tokens
Map to SwiftUI system colors. No Asset Catalog entries needed. Light/dark automatic.

| Token | SwiftUI | Usage |
|-------|---------|-------|
| `surface.page` | `Color(.systemGroupedBackground)` | Screen/page background |
| `surface.card` | `Color(.secondarySystemGroupedBackground)` | Interactive card — always has shadow |
| `surface.cardSubtle` | `Color(.tertiarySystemGroupedBackground)` | Non-interactive display card — no shadow |
| `surface.navigationBar` | `Color(.systemBackground)` | Nav bar background |
| `surface.tabBar` | `Color(.systemBackground)` | Tab bar background |
| `surface.input` | `Color(.secondarySystemBackground)` | Text input background |
| `surface.overlay` | `Color(.black).opacity(0.48)` | Modal/sheet backdrop |
| `text.primary` | `Color(.label)` | Main text, headers |
| `text.secondary` | `Color(.secondaryLabel)` | Supporting text, descriptions |
| `text.tertiary` | `Color(.tertiaryLabel)` | Captions, labels, placeholders |
| `text.inverse` | `Color(.systemBackground)` | Text on ink fills — primary button label |
| `text.placeholder` | `Color(.placeholderText)` | Input placeholder |
| `border.default` | `Color(.label)` | Border on interactive cards and buttons |
| `border.subtle` | `Color(.separator)` | Dividers, nav bar bottom, subtle separators |
| `border.opaque` | `Color(.opaqueSeparator)` | Separators over non-white backgrounds |
| `fill.buttonPrimary` | `Color(.label)` | Primary button fill |
| `fill.buttonSecondary` | `Color(.secondarySystemGroupedBackground)` | Secondary button fill |
| `icon.default` | `Color(.label)` | Default icon color |
| `icon.subtle` | `Color(.tertiaryLabel)` | Inactive tab icons |
| `shadow.interactive` | `.shadow(color: colorScheme == .dark ? .black : Color(.label), radius: 0, x: 3, y: 3)` | All interactive cards and buttons at rest |
| `shadow.interactivePressed` | `.shadow(color: colorScheme == .dark ? .black : Color(.label), radius: 0, x: 1, y: 1)` | Pressed state |
| `shadow.none` | no modifier | Non-interactive display elements |
| `special.heatmap.none` | `Color(.tertiarySystemFill)` | No activity recorded |
| `special.mood.unselected` | `Color(.secondarySystemFill)` | Unselected mood option |
| `special.sparkleMotif.outlined` | `Color(.label)` | Outline-only ✦ sparkle |

### Sport tokens
Resolved via active ThemeManager. Add each `assetName` to Asset Catalog as a Color Set with light/dark slots.

| Token | Usage |
|-------|-------|
| `sport.primary` | Main accent — icons, active states, progress fills |
| `sport.primary.text` | Text in sport primary color — scores, metric values |
| `sport.secondary` | Supporting accent — highlights, sparkle motif |
| `sport.surface` | Tinted card background |
| `sport.surface.subtle` | Very light tint — pill/tag backgrounds |
| `sport.border` | Border on sport-tinted cards and tags |
| `sport.shadow` | Hard offset shadow tinted to sport color |
| `sport.icon.background` | Circle fill behind activity icons |
| `sport.heatmap.low` | Low-intensity heatmap cell |
| `sport.heatmap.mid` | Mid-intensity heatmap cell |
| `sport.heatmap.high` | High-intensity heatmap cell |

### Sport themes
Switch via ThemeManager EnvironmentObject. Gymnastics is default.

**Gymnastics**
| Token | Light | Dark | Asset Name |
|-------|-------|------|------------|
| `sport.primary` | `#C85E3A` | `#E07A55` | `gymnastics-primary` |
| `sport.primary.text` | `#C85E3A` | `#E07A55` | `gymnastics-primary-text` |
| `sport.secondary` | `#E8A820` | `#F0C040` | `gymnastics-secondary` |
| `sport.surface` | `#EDD5C8` | `#2E1E18` | `gymnastics-surface` |
| `sport.surface.subtle` | `#F9EDE7` | `#261A14` | `gymnastics-surface-subtle` |
| `sport.border` | `#C85E3A` | `#E07A55` | `gymnastics-border` |
| `sport.shadow` | `#C85E3A` | `#7A3520` | `gymnastics-shadow` |
| `sport.icon.background` | `#C85E3A` | `#7A3520` | `gymnastics-icon-bg` |
| `sport.heatmap.low` | `#F9EDE7` | `#261A14` | `gymnastics-heatmap-low` |
| `sport.heatmap.mid` | `#E09070` | `#5A3020` | `gymnastics-heatmap-mid` |
| `sport.heatmap.high` | `#C85E3A` | `#E07A55` | `gymnastics-heatmap-high` |

**Figure Skating**
| Token | Light | Dark | Asset Name |
|-------|-------|------|------------|
| `sport.primary` | `#9B8AC8` | `#B8A8DC` | `skating-primary` |
| `sport.primary.text` | `#5E3A6E` | `#C8B8E8` | `skating-primary-text` |
| `sport.secondary` | `#D4637A` | `#E88098` | `skating-secondary` |
| `sport.surface` | `#E4DFEF` | `#1E1830` | `skating-surface` |
| `sport.surface.subtle` | `#F3F1F9` | `#181428` | `skating-surface-subtle` |
| `sport.border` | `#9B8AC8` | `#5E4A90` | `skating-border` |
| `sport.shadow` | `#9B8AC8` | `#352660` | `skating-shadow` |
| `sport.icon.background` | `#9B8AC8` | `#352660` | `skating-icon-bg` |
| `sport.heatmap.low` | `#F3F1F9` | `#181428` | `skating-heatmap-low` |
| `sport.heatmap.mid` | `#BDB0DC` | `#2E2448` | `skating-heatmap-mid` |
| `sport.heatmap.high` | `#9B8AC8` | `#B8A8DC` | `skating-heatmap-high` |

**Mental Health** — overrides active sport on all mental health screens
| Token | Light | Dark | Asset Name |
|-------|-------|------|------------|
| `sport.primary` | `#5E3A6E` | `#9B72B0` | `mental-primary` |
| `sport.primary.text` | `#5E3A6E` | `#C8A8DC` | `mental-primary-text` |
| `sport.secondary` | `#9B72B0` | `#7A5890` | `mental-secondary` |
| `sport.surface` | `#DDD0E8` | `#1E1428` | `mental-surface` |
| `sport.surface.subtle` | `#F4F0F8` | `#181020` | `mental-surface-subtle` |
| `sport.border` | `#5E3A6E` | `#9B72B0` | `mental-border` |
| `sport.shadow` | `#5E3A6E` | `#2E1A38` | `mental-shadow` |
| `sport.icon.background` | `#5E3A6E` | `#2E1A38` | `mental-icon-bg` |
| `sport.heatmap.low` | `#F4F0F8` | `#181020` | `mental-heatmap-low` |
| `sport.heatmap.mid` | `#9B72B0` | `#3A2048` | `mental-heatmap-mid` |
| `sport.heatmap.high` | `#5E3A6E` | `#9B72B0` | `mental-heatmap-high` |

### Special tokens
RESERVED. Add to Asset Catalog as Color Sets.

| Token | Light | Dark | Asset Name | Rule |
|-------|-------|------|------------|------|
| `special.achievement.fill` | `#E84A30` | `#FF6B50` | `achievement-fill` | Personal best / streak / goal only |
| `special.achievement.surface` | `#F5D0CA` | `#2E1410` | `achievement-surface` | Achievement card background |
| `special.achievement.border` | `#E84A30` | `#FF6B50` | `achievement-border` | Achievement badge border |
| `special.achievement.text` | `#E84A30` | `#FF6B50` | `achievement-text` | Achievement badge label |
| `special.achievement.sparkle` | `#E8A820` | `#F0C040` | `achievement-sparkle` | Sparkle burst fill |
| `special.mood.selected` | `#DDD0E8` | `#2E1A38` | `mood-selected` | Selected mood background |
| `special.mood.selectedShadow` | `Color(#5E3A6E).opacity(0.35)` | `Color(#9B72B0).opacity(0.40)` | — | Glow on selected mood emoji |
| `special.sparkleMotif.filled` | `#E8A820` | `#F0C040` | `sparkle-filled` | Filled ✦ hero moments |

### Color rules
- NEVER hardcode hex in components — always use token names
- NEVER use mint, teal, or blue-green hues anywhere
- `special.achievement.*` is reserved — never decorative
- `surface.card` always paired with `shadow.interactive`
- `surface.cardSubtle` never has shadow
- Mental health theme overrides active sport theme on all mental health screens

---

## Typography

| Role | Family | Weight | Size | Tracking | Line Height |
|------|--------|--------|------|----------|-------------|
| Display / Score hero | Sharpie | Heaviest available | 48–72pt | -0.03em | 0.95 |
| Section header | Sharpie | Bold | 24–32pt | -0.02em | 1.1 |
| Card header | Sharpie | Bold | 18–22pt | -0.01em | 1.1 |
| All-caps label | Sharpie or DM Sans | Bold | 10–12pt | +0.18em | — |
| Body | DM Sans | 400 | 15–17pt | 0 | 1.65 |
| Supporting / caption | DM Sans | 300 | 12–14pt | 0 | 1.6 |

| Text role | Token |
|-----------|-------|
| Headers, card titles | `text.primary` |
| Body, descriptions | `text.secondary` |
| Labels, captions, placeholders | `text.tertiary` |
| Primary button label | `text.inverse` |
| Score / metric values | `sport.primary.text` |
| Achievement values | `special.achievement.text` |

**Rules**
- NEVER use Inter, SF Pro, Roboto, Sharpie, or system fonts for headers — always Sharpie
- NEVER use DM Sans weight 600 or 700 — body stays 300–400
- Score values always Sharpie heaviest weight — must feel like they land
- All-caps labels minimum +0.15em tracking
- SwiftUI usage: `Font.custom("Sharpie-[WeightName]", size: N)` — replace WeightName with exact font file name

---

## Spacing Scale (8pt grid)

| Token | Value | Usage |
|-------|-------|-------|
| `space-1` | 8pt | Icon padding, tight gaps |
| `space-2` | 16pt | Screen margins, component padding |
| `space-3` | 24pt | Card padding, section spacing |
| `space-4` | 32pt | Between cards |
| `space-5` | 40pt | Section spacing |
| `space-6` | 48pt | Large section breaks |
| `space-8` | 64pt | Hero breathing room |

---

## Corner Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radius-sm` | 10pt | Tags, pills |
| `radius-md` | 14pt | Inputs, small cards |
| `radius-lg` | 20pt | Standard cards |
| `radius-xl` | 28pt | Large cards, modals |
| `radius-pill` | 100pt | Buttons, chips |

---

## Shadows & Interactivity

**Core rule: shadow = tappable. No shadow = display only. Never deviate.**

| State | Token | Spec |
|-------|-------|------|
| Interactive resting | `shadow.interactive` | x:3 y:3 blur:0 `Color(.label)` / black dark |
| Interactive pressed | `shadow.interactivePressed` | x:1 y:1 blur:0 `Color(.label)` / black dark |
| Sport-tinted | `sport.shadow` | x:3 y:3 blur:0 sport color |
| Non-interactive | `shadow.none` | none |

On press: card translates +2pt x/y + shadow shrinks simultaneously. Duration 100ms.

---

## Card System

**Interactive card**
```
background:    surface.card
border:        1.5pt solid border.default
border-radius: radius-lg
shadow:        shadow.interactive
padding:       space-3
```

**Sport-tinted interactive card**
```
background:    sport.surface
border:        1.5pt solid sport.border
shadow:        sport.shadow
border-radius: radius-lg
padding:       space-3
```

**Mental health card**
```
background:    sport.surface     (mentalHealth theme)
border:        1.5pt solid sport.border
shadow:        sport.shadow
border-radius: radius-xl
padding:       space-3
```

**Non-interactive display card**
```
background:    surface.cardSubtle
border:        1pt solid border.subtle
shadow:        none
border-radius: radius-lg
```

---

## Components

### Activity Card
```
background:    surface.card
border:        1.5pt solid border.default
border-radius: radius-lg
shadow:        shadow.interactive
padding:       space-3

Layout:
  [Icon 52pt] [Name — Sharpie 700 18pt text.primary]
              [Metric — Sharpie 700 18pt sport.primary.text, right-aligned]
              [Period — DM Sans 300 13pt text.tertiary, right-aligned]

Expanded (tapped):
  Row between cards: rotating action button (left) + heatmap grid (right)

Press: translate +2pt x/y, shadow → shadow.interactivePressed
```

### Activity Icon
```
container:     52pt circle, sport.icon.background, 1.5pt border.default, 2pt 2pt 0 border.default shadow
icon:          bold outlined flat SVG, surface.card fill, 2pt border.default stroke
nav variant:   24pt, sport.primary (active) / icon.subtle (inactive)
```

### Rotating Action Button
```
outer-diameter: 140pt
orbit-text:    "START SESSION [emoji] START SESSION [emoji]"
               DM Sans 400 12pt text.primary
center-icon:   ▶ or + at 32pt, text.primary
animation:     rotate 8s linear infinite, slow to 16s on hover
usage:         ONE per screen — primary action only
```

### Heatmap Grid
```
columns:       7, rows: N
cell:          20×20pt, gap 3pt, radius 4pt
colors:        special.heatmap.none / sport.heatmap.low / .mid / .high
sport icon:    16pt sport.primary, top-right above grid
```

### Score Card
```
large:
  label:       DM Sans 300 12pt text.tertiary all-caps tracked
  value:       Sharpie 800 56pt sport.primary.text
  sub:         DM Sans 300 14pt text.secondary
  card:        surface.card, radius-lg, shadow.interactive

compact:
  label:       DM Sans 300 11pt text.tertiary all-caps tracked
  value:       Sharpie 700 28pt sport.primary.text, right-aligned
```

### Circular Progress Widget
```
track:         6pt border.subtle
fill:          6pt sport.primary, round linecap, starts -90deg
center:        Sharpie 700 14pt text.primary + DM Sans 300 11pt text.tertiary
sizes:         96pt large · 80pt standard · 56pt compact
```

### Mental Health Check-in Card
```
Apply:         mentalHealth theme (overrides active sport)
card:          sport.surface bg, sport.border 1.5pt, sport.shadow, radius-xl, space-3 padding

header:        Sharpie 700 16pt text.primary
subheader:     DM Sans 300 13pt text.tertiary
mood row:      5 emoji 22pt — special.mood.unselected / special.mood.selected + selectedShadow
input:         surface.input bg, border.subtle 1pt, radius-md
submit:        secondary button, sport.border / sport.primary.text

NEVER: non-mentalHealth sport tokens, numerical scores, heatmaps, sport-tinted shadows
```

### Session Logged Confirmation
```
Animation: card slides up 300ms → checkmark draws 300ms → achievement burst if personal best 400ms

card:          surface.card, radius-xl, shadow.interactive, space-4 padding
  icon:        64pt bold outlined flat
  heading:     Sharpie 700 22pt text.primary
  score:       Sharpie 800 48pt sport.primary.text
  meta:        DM Sans 300 14pt text.tertiary
  badge:       achievement badge if personal best
```

### Achievement Badge
```
ONLY FOR: personal best, streak milestone, goal completed. NEVER decorative.

background:    special.achievement.surface
border:        1.5pt special.achievement.border
border-radius: radius-pill
text:          Sharpie 700 11pt special.achievement.text all-caps + ✦ sparkle left
entry:         scale 0.8→1.0 + fade, 200ms spring
burst:         4–6 sparkles radiate, special.achievement.sparkle fill, 400ms, ONCE per session
```

### Pill Tag
```
font:          Sharpie or DM Sans 700 11pt all-caps tracked +0.15em
height:        28pt, padding: 0 14pt, border-radius: radius-pill
border:        1.5pt sport.border
background:    sport.surface.subtle
text:          sport.primary.text
mental health: apply mentalHealth theme — tokens auto-resolve
```

### Primary Button
```
font:          Sharpie 700 14pt tracked +0.02em
background:    fill.buttonPrimary
text:          text.inverse
border:        1.5pt border.default
border-radius: radius-pill
height:        52pt, padding: 0 space-3
shadow:        shadow.interactive
press:         translate +2pt, shadow → shadow.interactivePressed
```

### Secondary Button
```
background:    fill.buttonSecondary
text:          text.primary
border:        1.5pt border.default
shadow:        shadow.interactive
(all other props same as primary)
```

### Navigation Bar
```
background:    surface.navigationBar
border-bottom: 1pt border.subtle
title:         Sharpie 700 18pt text.primary centered
left:          back chevron or ··· icon.subtle
right:         + sport.primary or text.primary
```

### Tab Bar
```
background:    surface.tabBar
border-top:    1pt border.subtle
icon:          24pt — sport.primary active / icon.subtle inactive
label:         DM Sans 400 10pt — sport.primary.text active / text.tertiary inactive
```

### Section Header
```
eyebrow:       DM Sans 700 11pt text.tertiary all-caps tracked +0.18em, margin-bottom space-1
title:         Sharpie 700 26pt text.primary, margin-bottom space-1
description:   DM Sans 300 15pt text.secondary (optional), margin-bottom space-3
```

### Activity Selection Sheet
```
presentation:  bottom sheet 90% height
header:        Sharpie 700 20pt text.primary + × close
section label: DM Sans 700 12pt text.tertiary all-caps tracked
tiles:         160×180pt, surface.card, sport.border 1.5pt, radius-lg, sport.shadow
               icon circle 56pt sport.icon.background
               Sharpie 700 16pt text.primary name + DM Sans 300 13pt text.tertiary type
```

### Empty State
```
illustration:  thin outline + spot color, 160×160pt centered, border.default stroke
sparkles:      2–3 ✦ special.sparkleMotif.filled or .outlined
heading:       Sharpie 700 22pt text.primary centered, margin-top space-3
body:          DM Sans 300 15pt text.secondary centered, max-width 260pt
CTA:           primary button, margin-top space-4
```

---

## Illustration System

**Register 1 — Bold Outlined Flat** (activity icons, nav icons)
```
stroke:        2–2.5pt border.default (auto-inverts in dark)
fill:          flat only — sport.surface.subtle base, sport.primary accent
gradients:     NEVER
minimum size:  48pt
two-tone max:  base fill + one accent
```

**Register 2 — Thin Outline + Spot Color** (achievement, empty states, backgrounds)
```
stroke:        1–1.5pt border.default
fill:          spot color only — selective, never overall
sparkle ✦:    special.sparkleMotif.filled (48pt hero · 28pt mid · 16pt accent)
               special.sparkleMotif.outlined (ambient)
```

---

## Ambient Backgrounds

Home/dashboard screens use illustrated sport scenes full-bleed. Cards float on top.

**Gymnastics scene**
```
base:          #F5E8D8 light / #1E1408 dark (hardcoded — physical scene)
elements:      balance beam, vault, floor lines, chalk haze
motifs:        sport.secondary sparkles
dark:          scene elements at 40% opacity
```

**Figure skating scene**
```
base:          #EDE9F5 light / #141020 dark (hardcoded — physical scene)
elements:      ice ellipse, rink circle, dashed skate trace curves
motifs:        sport.primary sparkles, sport.secondary stars
dark:          scene elements at 40% opacity
```

Cards always use `surface.card` — no scene color bleeds into cards.

---

## Motion

| Interaction | Duration | Easing | Notes |
|-------------|----------|--------|-------|
| Card press | 100ms | ease-out | translate +2pt + shadow compress |
| Rotating action button | 8s | linear infinite | Slow to 16s on hover |
| Achievement burst | 400ms | ease-out | Fires once per session only |
| Session logged checkmark | 300ms | ease-out | Path draw |
| Screen transition | 300ms | ease-out | Slide from right |

Always wrap in `prefers-reduced-motion`.

---

## Screen-Level Rules

**Every screen**
- Background: `surface.page`
- Horizontal margins: `space-2` (16pt)
- Nav bar: Sharpie 700 18pt `text.primary`, `surface.navigationBar`, 1pt `border.subtle` bottom
- Tab bar: `surface.tabBar`, `sport.primary` active, `icon.subtle` inactive

**Dashboard / home**
- Illustrated ambient background full-bleed
- `surface.card` cards floating on top
- Hero metric at top of first card

**Data-heavy screens (training log, scores)**
- `surface.page` only — no illustration
- Cards stacked, `space-2` gap
- Section headers: Sharpie 700 22pt + all-caps eyebrow

**Mental health screens**
- Apply `mentalHealth` theme — overrides active sport
- `space-5+` between elements
- `radius-xl` preferred
- No heatmaps, no numerical scores, qualitative only

---

## SwiftUI Implementation Reference

```swift
import SwiftUI

extension Color {
    // MARK: — Semantic (system colors, free light/dark)
    static let surfacePage          = Color(.systemGroupedBackground)
    static let surfaceCard          = Color(.secondarySystemGroupedBackground)
    static let surfaceCardSubtle    = Color(.tertiarySystemGroupedBackground)
    static let surfaceInput         = Color(.secondarySystemBackground)
    static let surfaceNavBar        = Color(.systemBackground)
    static let surfaceTabBar        = Color(.systemBackground)
    static let textPrimary          = Color(.label)
    static let textSecondary        = Color(.secondaryLabel)
    static let textTertiary         = Color(.tertiaryLabel)
    static let textInverse          = Color(.systemBackground)
    static let textPlaceholder      = Color(.placeholderText)
    static let borderDefault        = Color(.label)
    static let borderSubtle         = Color(.separator)
    static let borderOpaque         = Color(.opaqueSeparator)
    static let fillButtonPrimary    = Color(.label)
    static let fillButtonSecondary  = Color(.secondarySystemGroupedBackground)
    static let iconDefault          = Color(.label)
    static let iconSubtle           = Color(.tertiaryLabel)

    // MARK: — Special (custom Asset Catalog colors)
    static let achievementFill      = Color("achievement-fill")
    static let achievementSurface   = Color("achievement-surface")
    static let achievementBorder    = Color("achievement-border")
    static let achievementText      = Color("achievement-text")
    static let achievementSparkle   = Color("achievement-sparkle")
    static let moodSelected         = Color("mood-selected")
    static let sparkleFilled        = Color("sparkle-filled")
}

// MARK: — ThemeManager
// Inject via EnvironmentObject. Components access via:
// @EnvironmentObject var theme: ThemeManager
// then use theme.primary, theme.surface, theme.shadow etc.
```
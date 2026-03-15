# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Vault & Edge** — iOS SwiftUI app for figure skating and gymnastics coaches. Full spec in `PRD.md`. Full development plan (architecture, phases, screen inventory, scoring logic, implementation notes) in `PROJECT_PLAN.md`. **Always read `PROJECT_PLAN.md` before starting any implementation work.**

## Key Conventions

- Design screens in **Pencil.dev** before implementing. See `PROJECT_PLAN.md` for screen priority order.
- Video bytes never leave the device. Store only `PHAsset.localIdentifier`; stream via `PHImageManager`.
- Sport-specific scoring logic lives in a `ScoringEngine` protocol — keep it separate from views.
- Update the phase checklists in `PROJECT_PLAN.md` as work completes.

## Working with Xcode Projects

**CRITICAL**: When creating new Swift files using the `Write` tool, they must be manually added to the Xcode project:

1. After creating any `.swift` file, **ALWAYS** inform the user they need to add it to Xcode
2. Provide clear instructions: drag file from Finder into appropriate Xcode group
3. Remind them to:
   - ☐ UNCHECK "Copy items if needed"
   - ☑ CHECK "ProjectTitanium" target

**Why**: Files created outside Xcode (via Write tool, terminal, etc.) exist on disk but aren't registered in `project.pbxproj`. The build will fail until files are added to the Xcode project.

**When this applies**: Every new `.swift` file created with Write tool
**When this doesn't apply**: Editing existing files (Edit tool) - no action needed

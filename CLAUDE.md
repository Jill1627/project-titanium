# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Vault & Edge** — iOS SwiftUI app for figure skating and gymnastics coaches. Full spec in `PRD.md`. Full development plan (architecture, phases, screen inventory, scoring logic, implementation notes) in `PROJECT_PLAN.md`. **Always read `PROJECT_PLAN.md` before starting any implementation work.**

## Key Conventions

- Design screens in **Pencil.dev** before implementing. See `PROJECT_PLAN.md` for screen priority order.
- Video bytes never leave the device. Store only `PHAsset.localIdentifier`; stream via `PHImageManager`.
- Sport-specific scoring logic lives in a `ScoringEngine` protocol — keep it separate from views.
- Update the phase checklists in `PROJECT_PLAN.md` as work completes.

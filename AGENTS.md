# Project Hearth Guide

This repository contains the Godot game. The design source of truth is the Obsidian vault at `docs/hearth-design-vault`.

## Before changing game behavior

- Read `00 Start Here/00 Start Here.md` in the design vault for the current direction.
- Read `00 Start Here/01 Design Guide.md`, then `04 Production/Design Questions.md` and the linked subject note for the system being changed.
- For current production work, read `04 Production/First Vertical Slice.md` and `04 Production/Prototype and Vertical Slices.md`.
- Record new design decisions in the vault before treating them as settled behavior.

## Current build target

Slices 0 and 1 are playable, and the minimum cumulative Slice 2 through Slice 6 promises are implemented. After restoring the Old Stone Ruins waystone, players can meet a neighborhood food need by harvesting moonroot, cooking hearth stew, and delivering it to the market. Contributions build individual Farming, Cooking, and Trade mastery; completion opens a persistent produce stall. Rooms support up to eight distinct active players, bounded empty-room pantry catch-up, personal trail provisions, and persistent friend-recoverable packs. The produce stall also opens the Hearthlight Festival, where one to eight players explicitly opt into a normalized three-checkpoint circuit; finishers earn cosmetic ribbons and the first run leaves a persistent neighborhood celebration. Focused and uninterrupted fresh-world Chromium passes verify the exported Web presentation and keyboard interaction path through Slice 5, while a focused Chromium pass and simultaneous two-client probe verify Slice 6. Linux deployment packaging is deferred and is not an active milestone.

First-person and over-the-shoulder cameras, movement smoothing, two-client networking, persistence, and Mac-to-Windows private-network runtime checks pass. For every change, run automated coverage and test the exported desktop Web build through Playwright CLI first. Broader runtime validation then proceeds to Windows desktop and native Android; native Mac is supplementary. Fresh-player and full Web/Android/Windows runtime validation are deferred until the game has taken more shape. Use Godot 4.x, GDScript, the Compatibility renderer, and WebSockets shared by all clients. Keep all shared-world rules server-authoritative.

## Verification

- Run the headless state test documented in `README.md` after changing world rules or persistence.
- Run a headless server plus at least two clients after changing networking.
- A slice is complete only after it passes on Windows, desktop Web, and Android.

## Agent skills

### Issue tracker

Issues and specs are tracked in this repository’s GitHub Issues. See `docs/agents/issue-tracker.md`.

### Triage labels

Use the five default triage labels. See `docs/agents/triage-labels.md`.

### Domain docs

Use the single-context domain documentation layout. See `docs/agents/domain.md`.

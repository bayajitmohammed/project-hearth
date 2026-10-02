# Project Hearth Guide

This repository contains the Godot game. The design source of truth is the Obsidian vault at `/Users/kyrin0/Desktop/studio/notes/mmo-party-game-exploration`.

## Before changing game behavior

- Read `00 Start Here.md` in the design vault for the current direction.
- Read `Design Questions.md`, then the linked subject note for the system being changed.
- For current production work, read `First Vertical Slice.md` and `Prototype and Vertical Slices.md`.
- Record new design decisions in the vault before treating them as settled behavior.

## Current build target

Slices 0 and 1 are playable, and the minimum cumulative Slice 2, Slice 3, and Slice 4 promises are implemented. After restoring the Old Stone Ruins waystone, players can meet a neighborhood food need by harvesting moonroot, cooking hearth stew, and delivering it to the market. Contributions build individual Farming, Cooking, and Trade mastery; completion opens a persistent produce stall. A focused Mac presentation check passed, but the uninterrupted cumulative Slice 3–4 Mac journey is still pending before work moves to Slice 5.

First-person and over-the-shoulder cameras, movement smoothing, two-client networking, persistence, and Mac-to-Windows private-network runtime checks pass. During the cumulative implementation pass, use automated coverage plus a developer-run Mac functionality and visual check for each feature; Windows may serve as the second player. Fresh-player and full Web/Android/Windows runtime validation are deferred until the game has taken more shape. Use Godot 4.x, GDScript, the Compatibility renderer, and WebSockets shared by all clients. Keep all shared-world rules server-authoritative.

## Verification

- Run the headless state test documented in `README.md` after changing world rules or persistence.
- Run a headless server plus at least two clients after changing networking.
- A slice is complete only after it passes on Windows, desktop Web, and Android.

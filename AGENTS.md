# Project Hearth Guide

This repository contains the Godot game. The design source of truth is the Obsidian vault at `/Users/kyrin0/Desktop/studio/notes/mmo-party-game-exploration`.

## Before changing game behavior

- Read `00 Start Here.md` in the design vault for the current direction.
- Read `Design Questions.md`, then the linked subject note for the system being changed.
- For current production work, read `First Vertical Slice.md` and `Prototype and Vertical Slices.md`.
- Record new design decisions in the vault before treating them as settled behavior.

## Current build target

Slice 0 is complete except for the intentionally deferred Windows runtime test. The active target is Slice 1, **A New Home**. Its first graybox increment contains the arrival road, damaged cottage, forest boundary, lost supplies, larger movement area, and a following camera.

Continue in the build order recorded in `Prototype and Vertical Slices.md`, starting with Mara and the shared cottage-repair request. Use Godot 4.x, GDScript, the Compatibility renderer, and WebSockets shared by all clients. Keep all shared-world rules server-authoritative.

## Verification

- Run the headless state test documented in `README.md` after changing world rules or persistence.
- Run a headless server plus at least two clients after changing networking.
- A slice is complete only after it passes on Windows, desktop Web, and Android.

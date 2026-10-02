# Project Hearth Guide

This repository contains the Godot game. The design source of truth is the Obsidian vault at `/Users/kyrin0/Desktop/studio/notes/mmo-party-game-exploration`.

## Before changing game behavior

- Read `00 Start Here.md` in the design vault for the current direction.
- Read `Design Questions.md`, then the linked subject note for the system being changed.
- For current production work, read `First Vertical Slice.md` and `Prototype and Vertical Slices.md`.
- Record new design decisions in the vault before treating them as settled behavior.

## Current build target

Slice 0 is complete and Slice 1, **A New Home**, is playable. The active target is Slice 2, **A Place That Remembers**. Its first cumulative increment begins after the cottage repair: Mara invites the players to light three shared welcome lanterns, moves to the gathering place, neighborhood morale improves, and the cottage repair and celebration enter the shared chronicle.

The adjustable third-person camera, fresh-player playtest, two-client networking probe, and Mac-to-Windows private-network runtime check pass. Retain the remaining Slice 1 full-loop cross-platform acceptance check as a regression item while building Slice 2. Use Godot 4.x, GDScript, the Compatibility renderer, and WebSockets shared by all clients. Keep all shared-world rules server-authoritative.

## Verification

- Run the headless state test documented in `README.md` after changing world rules or persistence.
- Run a headless server plus at least two clients after changing networking.
- A slice is complete only after it passes on Windows, desktop Web, and Android.

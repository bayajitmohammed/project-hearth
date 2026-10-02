---
tags: [game-design, vertical-slice, production]
---

# First Vertical Slice — A New Home

> [[00 Start Here|Home]] › [[01 Design Guide|Design Guide]] › **04 Production** · Roadmap: [[Prototype and Vertical Slices]]

## Promise

In one 20–30 minute session, 1–4 newcomers work together to earn and repair their first shared home. When they return, the world remembers them.

## Player experience

1. Arrive at one street outside the city and meet **Mara**, caretaker of an abandoned cottage.
2. Accept her offer: repair the cottage in exchange for helping the neighborhood.
3. Enter a small forest to gather wood and healing herbs and recover a lost supply cart.
4. Avoid or confront one simple creature. Players can revive each other.
5. Return, craft a repair kit, and place three cottage improvements together.
6. Mara recognizes the result, the group receives its first reputation point, and a new map rumor appears.
7. Leave and reload. The repaired cottage, inventory, reputation, and Mara's dialogue persist.

## Build only this

- Windows, desktop browser, and Android clients with the same room-code flow
- One authoritative online room for 1–4 players
- Movement, interaction, one inventory, one resource tool, one craft recipe, and three building placements
- One NPC with two states, one creature, one revive action, and one shared quest
- One tiny authored street and one small generated forest seed
- Server save/load for one world
- Keyboard/mouse, controller, and basic touch controls

Use graybox or clearly licensed placeholder art. AI-made production assets begin only after an asset provenance and review process exists.

## Done when

- A Windows, browser, and Android player can finish the loop together.
- A new player understands the goal without developer explanation.
- Disconnecting and rejoining does not lose or duplicate items.
- Reloading shows the repaired home and changed NPC response.
- At least one playtest group discusses what they want to do next.

## Not in this slice

Eight-player scaling, character creation, skill trees, farming, economy, day/night schedules, large procedural worlds, PvP, Discord, final art, and monetization.

## Technical prerequisite — Slice 0

Before making content, prove that the three target clients can join one room, move, pick up one object exactly once, disconnect, reconnect, and load the saved state. This is a disposable networking test, not the vertical slice.

## Implementation progress

- [x] Slice 0 authoritative multiplayer and persistence proof
- [x] Graybox arrival road, damaged cottage, forest boundary, and adjustable 360° following camera
- [x] Mara and the shared cottage-repair request
- [x] Shared project materials, repair-kit recipe, and three persistent repairs
- [x] One forest creature, player defeat, and cooperative revive
- [x] Full state persistence, reputation, map rumor, and first-time guidance
- [x] Shared room-code entry, four-player cap, and isolated fresh-save playtest option
- [x] First playtest readability fix: compact quest HUD, repair progress, front-facing labeled markers, and proximity prompt
- [x] Mac, Web, and Android build/render/connect/movement smoke tests
- [x] Two simultaneous Mac clients verify shared quest progress, resource duplication prevention, and revival
- [x] Fresh-player quest-loop playtest and follow-up family playtest
- [x] Windows exported runtime connects to the Mac server; Mac and Windows players are mutually visible
- [x] Vertical camera direction corrected after the Windows playtest
- [ ] Deferred release validation: repeat the full cumulative loop with fresh players across the target clients once the game has taken more shape

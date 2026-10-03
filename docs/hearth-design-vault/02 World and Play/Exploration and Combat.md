---
tags: [game-design, exploration, combat]
---

# Exploration and Combat

> [[00 Start Here|Home]] › [[01 Design Guide|Design Guide]] › **02 World and Play** · Previous: [[Living World]] · Next: [[Stories and Consequences]]

## Exploration

The map begins incomplete. Players learn from roads, rumors, high points, NPC directions, and physical landmarks. Discoveries add shared map notes and may reveal resources, people, mysteries, or events—not only treasure.

Travel should feel risky and interesting on the first visit, then convenient. Repaired routes, mounts, boats, and discovered waypoints make repeat journeys faster.

## Combat

Combat is accessible 3D action in either the default first-person view or the close over-the-shoulder third-person view: basic attack, charged or alternate action, dodge or guard, tool use, and a small ability loadout. Weapons and magic offer distinct roles without permanent classes.

Enemies reward observation, positioning, cooperation, and using the environment. Combat is important in dangerous areas but is only one route to reputation and progress; many sessions contain none.

The first combat-pacing rule is a short authoritative recovery after each successful basic attack. Recovery belongs to the attacking player, so companions can act independently; an input during recovery deals no damage. Missing or attacking out of range does not consume recovery. This transient timing resets with the runtime and is not equipment, mastery, or permanent power.

The first alternate action is **Power Strike**, available to every newcomer. It uses the same range and target rules as the basic attack and deals two damage immediately, but commits that player to a substantially longer authoritative recovery. A failed or out-of-range attempt consumes nothing. Each successful Power Strike grants one Combat mastery credit for the action rather than one credit per point of damage. This creates a deliberate low-input option without increasing sustained damage or making mastery into combat power.

The first defensive action is **Brace**. A standing player braces briefly; the next forest-creature or ruin-guardian hit during that window is blocked and consumes the brace. Activating it begins a short personal cooldown whether or not a hit arrives, so defense rewards timing instead of repeated input. Brace is available to every newcomer, is independent for each companion, and is cleared on reconnect or runtime restart rather than becoming persistent power.

Forest-creature and ruin-guardian attacks use a short authoritative **wind-up** before damage. The wind-up visibly names one locked target for every client. That player can react by bracing or by leaving strike range; a target who is disconnected, downed, or out of range when the wind-up completes is not hit. Other companions remain free to attack, brace, move, or aid during the warning. Wind-up and target state are transient and never written into the world save.

Each authored enemy also belongs to a readable **home area**. It only pursues standing players who remain inside that encounter boundary. When no eligible player remains engaged, it cancels pending pressure, visibly returns to its spawn, and restores full health after reaching home. Another companion who stays inside the boundary can keep the encounter active. The server owns pursuit, return movement, and the completed reset in every play mode, preventing enemies from being dragged into peaceful neighborhood spaces or defeated through consequence-free long-distance kiting.

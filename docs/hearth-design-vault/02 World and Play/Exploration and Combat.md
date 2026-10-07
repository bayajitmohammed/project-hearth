---
tags: [game-design, exploration, combat]
---

# Exploration and Combat

> [[00 Start Here|Home]] › [[01 Design Guide|Design Guide]] › **02 World and Play** · Previous: [[Living World]] · Next: [[Stories and Consequences]]

## Exploration

The map begins incomplete. Players learn from roads, rumors, high points, NPC directions, and physical landmarks. Discoveries add shared map notes and may reveal resources, people, mysteries, or events—not only treasure.

Travel should feel risky and interesting on the first visit, then convenient. Repaired routes, mounts, boats, and discovered waypoints make repeat journeys faster.

After the Old Stone Ruins waystone route is restored, Northwood offers one deterministic **trail survey** each world day. The shared marker rotates among a small authored set, but every standing player may record it once that day for one personal Exploration mastery point; one companion never consumes another's opportunity. The last recorded day persists per identity. Empty-world calendar catch-up may change which marker is current, but never records a survey or awards mastery. This makes repeat travel purposeful without privatizing the shared map or adding passive progression.

Completing **Nima's Bearings** reveals her first follow-up destination at the homestead map table: **Moonwell Glade**, a sheltered spring on the western edge of Northwood. Any player may study the table, another may discover the glade, and companions may attune its three dormant moonstones in any order across sessions. Discovery and each first stone attunement award normal personal Exploration mastery to the player who performed that action; the landmark and its outcome remain shared immediately.

Attuning all three stones permanently wakes the luminous spring, raises neighborhood morale and reputation once, and records the sanctuary in the shared chronicle. The restored Moonwell becomes a second safe recovery point where any standing injured player can rest without consuming supplies, advancing time, or affecting companions. It cannot revive a downed player. The story has no timer, one player may complete every step alone, and empty-world catch-up cannot reveal, attune, or complete it.

## Briarwatch — a marked-ground encounter

Restoring the ruins route reveals a northern outing to **Briarwatch**, an abandoned watch clearing beyond the Old Stone Ruins. A trail marker explicitly begins the encounter. Players break three separated spirit bindings with E, then rekindle the watch beacon. Broken bindings persist across retreats, defeat, disconnects, and sessions; nobody must remain online to own the outing.

While bindings remain, the watch spirit periodically marks a standing traveler's current ground position for 1.2 seconds before one pulse strikes a 2.4-metre circle. The mark does not chase its target. Any standing active player still inside at impact risks one health; leaving the circle, a timed brace, or existing nearby Guardian interception can prevent the hit. Targets rotate through eligible identities, not increased enemy health. Friends may draw a mark aside while others work on bindings; one player can evade and finish all three alone. Ordinary attacks do not damage the spirit: its visible bindings are the objective, and this is stated in the guidance.

The warning and cooldown are transient. Empty worlds and empty clearings cancel pending pulses, and rejoining never resumes a saved surprise hit. Damage stays inside the clearing and never reaches homes. Each first broken binding grants normal Exploration mastery to its contributor. Rekindling the beacon awards one shared morale/reputation/chronicle outcome, permanently ends the danger, and leaves a beacon that any standing traveler can use to return home. This is an authored encounter and new place, not continent streaming or final encounter scaling.

### Cooperative pressure waves

Briarwatch now scales simultaneous marked ground by standing active participants inside the clearing: one mark for a solo traveler, two for two to four travelers, and three for five to eight. Each wave locks distinct travelers' positions in stable rotating identity order. All circles share the existing 1.2-second warning, radius and three-second recovery; health, binding count and rewards do not inflate. Spread out, draw marks away from bindings, and coordinate brace/interception while companions complete the three jobs.

Overlapping circles can threaten a player only once per wave, so a valid brace still protects against that wave. Existing Guardian interception remains one hit per brace. New arrivals and departures affect the next wave; marks already shown do not move or multiply mid-warning. Only currently active standing players inside the clearing can be struck, and an empty clearing cancels all marks. Broken bindings survive party-size changes and restarting; pending waves remain transient and are never saved.

## Combat

Combat is accessible 3D action in either the default first-person view or the close over-the-shoulder third-person view: basic attack, charged or alternate action, dodge or guard, tool use, and a small ability loadout. Weapons and magic offer distinct roles without permanent classes.

Enemies reward observation, positioning, cooperation, and using the environment. Combat is important in dangerous areas but is only one route to reputation and progress; many sessions contain none.

The first combat-pacing rule is a short authoritative recovery after each successful basic attack. Recovery belongs to the attacking player, so companions can act independently; an input during recovery deals no damage. Missing or attacking out of range does not consume recovery. This transient timing resets with the runtime and is not equipment, mastery, or permanent power.

The first alternate action is **Power Strike**, available to every newcomer. It uses the same range and target rules as the basic attack and deals two damage immediately, but commits that player to a substantially longer authoritative recovery. A failed or out-of-range attempt consumes nothing. Each successful Power Strike grants one Combat mastery credit for the action rather than one credit per point of damage. This creates a deliberate low-input option without increasing sustained damage or making mastery into combat power.

The first defensive action is **Brace**. A standing player braces briefly; the next forest-creature or ruin-guardian hit during that window is blocked and consumes the brace. Activating it begins a short personal cooldown whether or not a hit arrives, so defense rewards timing instead of repeated input. Brace is available to every newcomer, is independent for each companion, and is cleared on reconnect or runtime restart rather than becoming persistent power.

The first active-loadout trade-off is chosen freely at the repaired cottage. The default **Vanguard** kit keeps the established combat timings. The **Guardian** kit makes brace more forgiving and reusable, while adding recovery to both successful attack types. It never changes damage, health, range, or access to actions. Because every player can switch either way at home without cost, the choice supports different outing roles without creating veteran-only power or permanent classes.

A braced Guardian can also **intercept** one incoming creature hit for a nearby companion. The threatened player always spends their own active brace first. Otherwise, an active, standing Guardian within two metres of both the companion and attacker spends their brace and prevents the hit; the nearest eligible Guardian to the companion wins, with stable player identity ordering breaking an exact tie. Vanguard braces protect only their owner. Interception changes positioning and coordination rather than health or damage, and its short feedback is transient rather than saved.

Forest-creature and ruin-guardian attacks use a short authoritative **wind-up** before damage. The wind-up visibly names one locked target for every client. That player can react by bracing or by leaving strike range; a target who is disconnected, downed, or out of range when the wind-up completes is not hit. Other companions remain free to attack, brace, move, or aid during the warning. Wind-up and target state are transient and never written into the world save.

Each authored enemy also belongs to a readable **home area**. It only pursues standing players who remain inside that encounter boundary. When no eligible player remains engaged, it cancels pending pressure, visibly returns to its spawn, and restores full health after reaching home. Another companion who stays inside the boundary can keep the encounter active. The server owns pursuit, return movement, and the completed reset in every play mode, preventing enemies from being dragged into peaceful neighborhood spaces or defeated through consequence-free long-distance kiting.

The ordinary forest creature is renewable local danger rather than a one-time loss of the combat loop. Defeating it keeps the forest safe for the rest of that authoritative world day; the next day returns it at full health and at home, including when bounded empty-room calendar catch-up crosses the day boundary. It grants only the normal per-action Combat mastery already available from fighting. The ruin guardian does not renew: its defeat remains a persistent authored story change tied to restoring the waystone.

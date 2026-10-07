---
tags: [game-design, simulation, world]
---

# Living World

> [[00 Start Here|Home]] › [[01 Design Guide|Design Guide]] › **02 World and Play** · Previous: [[World Shape and Building]] · Next: [[Exploration and Combat]]

## Question

What makes the world feel alive rather than empty?

## Answer

The world runs on four visible systems:

- NPCs have homes, work, relationships, routines, and short-term needs.
- Settlements track local conditions such as safety, supply, morale, and faction trust.
- An event director creates opportunities and trouble from those conditions.
- Characters and locations remember important player choices.

Simulation exists to create readable situations, not to imitate every detail of life. Events are tied to people and places the group knows, and outcomes cause small persistent changes. Empty wilderness remains useful as contrast, but travel is punctuated by signs, travelers, creatures, and discoveries.

## First routine and calendar depth

The first reusable layer is an authoritative neighborhood clock. One real second advances one game minute while at least one player is active, creating a 24-minute prototype day. The current day and time persist with the world. When an empty world wakes, its calendar may advance by at most six game hours; this catch-up is informational and can never make a player miss an event or suffer damage.

Required story appearances override routines so an NPC can never wander away from an active objective. After Welcome Lights is complete, Mara follows the first readable daily routine:

- **Morning, 06:00–11:59:** tends the cottage.
- **Afternoon, 12:00–17:59:** helps at the market when the produce stall is open, or meets neighbors at the gathering place before then.
- **Evening, 18:00–21:59:** spends time at the gathering place.
- **Night, 22:00–05:59:** rests at the cottage.

The HUD names the day, time of day, and Mara's current activity. This is a small proof of a reusable clock and NPC schedule, not a commitment to simulating every NPC continuously.

Mara's routine also supports one optional personal check-in per player per world day after Welcome Lights. The server records the last check-in day separately for each persistent identity, so offline and cooperative players receive the same opportunity without repeated-input farming or one player consuming the room's conversation.

The restored Old Stone Ruins route drives the first resident arrival condition: Nima appears at the home waystone and remains available while her shared field-case story is unresolved. After that story is complete, she follows a small readable routine—mapping at her homestead table in the morning, studying the home waystone in the afternoon, meeting neighbors at the gathering place in the evening, and resting by the cottage at night. Her routine changes presentation only; it never makes the request missable or advances while the room is empty.

Nima's completed map table also exposes the authored Moonwell Glade lead. Restoring its three dormant stones leaves a permanent luminous sanctuary in Northwood. This is a remembered place change driven only by player actions: weather, routine simulation, and empty-world calendar catch-up may change its ambience but never advance its restoration.

## Neighborhood visits — implementation scope

A small event director selects one persistent visit at the eastern market green while players are active. **Travelers' Rest** becomes eligible after the produce stall opens when rain falls or Fartrail Outpost is complete: travelers ask for two shared wood for shelter and two personal provisions for meals. **Seedkeepers' Exchange** becomes eligible after Sera's welcome: visitors ask for two shared herbs and two shared moonroot. Each visit has two separate nearby job stations; E contributes one named ingredient, and companions may divide the work or finish it alone.

Eligible visit types never completed take priority; otherwise the least-completed eligible type wins, with saved seed/day breaking ties. There is only one outstanding visit and no deadline. Partial jobs persist across days, weather changes, disconnects and restarts. A completed visit cannot be replaced until a later world day. Empty-world catch-up neither selects nor contributes to visits, and missed days never queue a backlog.

Each type's first completion leaves a permanent market-green feature (a travelers' canopy or seed planter), one chronicle entry and one morale/reputation gain. Every completed visit adds at most one provision to the existing bounded pantry; it grants no personal coin, mastery or exclusive access. Subsequent visits reuse the place and do not repeat milestone rewards or flood the chronicle. This is the first reusable condition-driven director with two authored templates, not a general settlement population, threat or faction simulation. Prototype quantities and graybox presentation remain subject to later playtesting.

## First weather and daylight depth

Each world day has one deterministic forecast derived from the region seed and authoritative day number: clear, overcast, or gentle rain. Every client receives the same named weather in the world snapshot, while daylight color and brightness follow the shared clock. Night remains navigable and inviting through cool ambient light and warm authored landmarks rather than becoming black.

Weather remains safe and non-punitive: it does not slow movement, damage crops, change combat, hide required objectives, or make absence costly. The first condition-aware response appears after the produce stall opens. Clear days favor a fresh-moonroot order, gentle rain creates demand for warming hearth stew, and overcast days use the existing day-parity rotation. The HUD names why the request was chosen, every option uses the same renewable garden, and empty-world calendar catch-up still leaves only the current day's request rather than stacking consequences.

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

## First weather and daylight depth

Each world day has one deterministic forecast derived from the region seed and authoritative day number: clear, overcast, or gentle rain. Every client receives the same named weather in the world snapshot, while daylight color and brightness follow the shared clock. Night remains navigable and inviting through cool ambient light and warm authored landmarks rather than becoming black.

This first weather layer is atmospheric. It does not slow movement, damage crops, change combat, hide required objectives, or make absence costly. Empty-world calendar catch-up may advance to a different day's forecast, but it cannot stack weather consequences. Later events and settlement needs may read weather only after they have their own readable warnings, player choices, and safe offline rules.

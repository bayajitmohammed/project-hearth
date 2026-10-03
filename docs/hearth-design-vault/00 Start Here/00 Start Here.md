---
tags:
  - game-design
  - exploration
---

# Multiplayer World Game — Current Direction

This is the concise source of truth.

## How to navigate this vault

1. Read this note for the current direction.
2. Open [[01 Design Guide]] for the ordered map of vision, world systems, progression, and production notes.
3. Use [[Design Questions]] when you need the accepted answer to a specific design question.
4. Use [[Prototype and Vertical Slices]] for implementation status and slice history.
5. Use [[Cumulative Slices 1-6 Playtest Checklist]] only while performing the current validation pass.

The information hierarchy is: **current direction → accepted decision → detailed subject note → production status → temporary active work**.

## Pitch

Up to eight friends leave a war-torn homeland and build new lives in a living fantasy world, becoming known through the homes, relationships, discoveries, and local history they create together.

## Where the idea started

The game comes from wanting something that friends and family can keep returning to together.

It should support:

- Playing alone or with roughly 2–8 people
- A persistent character that grows over time
- A persistent world the group becomes attached to
- Relaxed activities as well as adventure and optional PvP
- Enough unpredictability to create memorable stories
- Reasons to play even when the entire group is not online

The emotional goal is:

> **This is our world. Things happened here because we played together.**

## Current direction

The world is closer in structure to **Minecraft** than to the earlier floating-island idea.

That means a large procedurally generated world where players can explore, gather resources, settle somewhere, improve their surroundings, and continue playing for a long time. The visual style does not need to resemble Minecraft, and the game does not necessarily need blocks or unrestricted destruction.

The setting is a lush magic-fantasy world with elves, magic, monsters, villages, and ancient ruins. The player characters come from a homeland ravaged by a long war. They arrive together in a large fantasy city with little money and no reputation, hoping to build new lives and make names for themselves. They may earn recognition through many paths—not only combat.

The important inspiration is the freedom of entering a generated world and deciding together what to do.

The major difference is that Minecraft can sometimes feel empty. This game should make the world feel more inhabited, eventful, and responsive.

## The experience

Players choose a goal, venture into the city or generated surrounding regions, then return to turn what they found into a better home, stronger relationships, or a growing reputation. Each session should leave a visible trace.

The world feels alive through NPC routines and relationships, settlement conditions, local events, and memories of important player choices. The group improves a shared homestead and nearby communities. A chronicle records the history they create.

The default camera is first person, with a toggle to a close over-the-shoulder third-person view. The third-person view stays near shoulder level rather than using a high or top-down angle.

## The three moods

The game may move naturally between three moods:

### Chill

Build, farm, fish, craft, decorate, manage, explore nearby, or simply spend time together.

### Adventure

Travel farther, discover locations, fight, complete objectives, find rare resources, and improve the character or home.

### Chaos

Unexpected events, friendly competition, PvP, monsters, disasters, unusual rules, and funny multiplayer situations.

These should ideally exist in the same world instead of feeling like three separate games.

## Progression

Separate mastery tracks let players become known for combat, farming, building, cooking, trade, exploration, or a mixture. Growth mainly unlocks options, convenience, and expression. Equipment is situational and functional power has a reachable cap, so a frequent player gains variety without making a newcomer irrelevant.

## Multiplayer

The game should work when:

- One person plays alone
- Two people casually play together
- A larger group gathers for an event or adventure
- Someone joins late or leaves early
- Different players have very different amounts of playtime

Players choose between a private offline world on their device, a player-hosted LAN world for nearby friends, or a networked room. All three modes run the same authoritative world rules; LAN hosting makes the host's game the authority, while networked rooms use a dedicated server. Losing internet access must never prevent someone from playing their own offline world.

Encounters scale through different threats and parallel jobs rather than inflated health. Players can join and leave without resetting an outing. Loot is personal and shared-project credit is automatic.

PvP exists only in opt-in world activities. Standard contests normalize power; an optional chaos mode uses personal gear.

## Production direction

Development is divided into cumulative playable slices, beginning with multiplayer and persistence, then proving the newcomer loop, living-world response, exploration, livelihoods, 2–8 player operation, and finally social activities and launch polish. See [[Prototype and Vertical Slices]].

Technical architecture, launch platforms, hosting, and the business model are summarized in [[Design Questions]] and supported by [[Technical and Business Research]]. Detailed system numbers and content lists remain future work.

The working production choice is Godot 4.x targeting Windows, desktop browsers, and native Android together. All three connect over secure WebSockets to authoritative rooms on a small capped Linux server; empty worlds sleep to control cost. Steam is a possible later Windows channel, not an initial requirement. Price will be chosen only after playable slices show the game's real value.

## What is no longer part of the direction

- **The Wandering Isles:** the floating home island and airship concept is removed.
- A disconnected collection of party minigames is not the current goal.
- Discord should not become the place where players repeatedly grind commands.
- The design should not assume that every attractive idea belongs in the finished game.

## Design discussion

The question index and current accepted answer to each question live in [[Design Questions]]. Detailed exploration belongs in a separate note for each subject.

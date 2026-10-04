---
tags:
  - game-design
  - progression
---

# Player Progression

> [[00 Start Here|Home]] › [[01 Design Guide|Design Guide]] › **03 Progression and Activities** · Next: [[Shared World Progression]]

## Questions

### Core question

> **How should a player's character become meaningfully different after many hours of play?**

### Parts to explore

1. **What grows?** One overall level, individual skills, equipment, abilities, reputation, collections, or some mixture?
2. **What does growth provide?** More numerical power, new options, convenience, specialization, expression, or access to new places?
3. **How is growth earned?** By doing an activity, spending points, finding loot, completing challenges, learning from the world, or another method?
4. **Can choices be changed?** Are builds permanent, freely changeable, costly to change, or unnecessary?
5. **How do unequal players stay compatible?** What happens when one family member has played for 100 hours and another has played for two?
6. **What is the long-term ceiling?** Does progression end, slow down, expand sideways, reset, or continue indefinitely?

## Discussion

Progression must create identity without making a frequent player too strong to enjoy the game with a newcomer.

## Answer

Characters improve through separate **mastery tracks** such as combat, farming, building, cooking, trade, and exploration. Using a skill and completing related goals earns mastery.

Mastery mainly unlocks new actions, recipes, tools, conveniences, and cosmetic signs of expertise. Equipment provides situational choices rather than an endless power ladder. A player chooses a small active loadout before an outing and can change it freely at home.

Each track has a reachable functional cap; long-term rewards become titles, appearance, collections, and reputation. Group activities scale to the group, while experienced players contribute through more options and knowledge—not overwhelming statistics.

## First outing-kit choice

The repaired cottage unlocks a gear rack where every player may freely swap their personal active outing kit. **Vanguard** is the default balanced kit and preserves the existing attack and brace timings. **Guardian** extends the brace window from 0.7 to 1.0 seconds and shortens its cooldown from 1.6 to 1.25 seconds, but adds 0.2 seconds of recovery to every successful basic or power attack. Damage, health, movement, range, mastery gain, and available actions remain unchanged.

The equipped kit persists with that player, is never dropped, and can only be changed while standing at the home rack. Both kits are available immediately after the shared cottage repair, require no mastery or currency, and may be swapped without cost. This establishes a reversible situational loadout and a cooperative role preference—not a permanent class or higher tier of power.

Guardian's first cooperative action is **interception**. While actively braced, a standing Guardian within two metres of both a companion and the attacking creature may spend that brace to prevent the companion's hit. The companion's own brace has priority; otherwise the closest eligible Guardian is chosen deterministically. Vanguard cannot intercept, and interception grants no mastery, damage, health, range, or permanent benefit. This makes the slower kit meaningfully protective only through timing and formation.

## First mastery conveniences

The first tier-II techniques reduce repeated inputs without improving combat statistics or excluding newcomers:

- **Farming II — Careful Tending:** one interaction may harvest the targeted ready plot and one adjacent ready plot.
- **Cooking II — Batch Cooking:** one interaction may cook the remaining stew requested when the shared bag already holds the full ingredients.
- **Trade II — Bulk Delivery:** one interaction may deliver the matching goods already prepared for the current market request.

Tier II begins at 4 Cooking or Trade mastery and 8 Farming mastery. Every item harvested, cooked, or delivered still grants its normal mastery credit, regardless of whether it was processed in one input. A player at mastery 0 can complete every request with the original actions, and friends may still divide the work. These are first convenience proofs, not final thresholds or a permanent skill-tree layout.

## First combat mastery identity

Each successful basic attack that damages a creature grants one personal **Combat mastery** point. The first point displays the identity title **Warden I** in the existing mastery readout. Misses, rejected attacks during recovery, bracing, and taking damage grant no credit.

This first layer records participation and gives the combat path a visible identity only. It does not change damage, health, attack recovery, brace timing, enemy strength, or access to the base combat actions, so a newcomer remains equally useful in an encounter. Later combat techniques must preserve that compatibility and need a separate design decision before implementation.

## First exploration mastery identity

The player who first reveals Northwood or the Old Stone Ruins for the shared map gains one personal **Exploration mastery** point for that discovery. The first point displays the identity title **Pathfinder I**. If one authoritative movement update crosses both reveal conditions, both genuinely new places grant their normal credit.

The map discovery itself remains shared immediately with the room. This identity layer does not change movement speed, waystone access, combat, reveal distance, or any route available to a newcomer. Future repeatable exploration work can provide more opportunities for personal credit without taking shared discoveries away from the group.

## First building mastery identity

Each cottage part successfully placed during the shared repair grants one personal **Building mastery** point to the player who performs that placement. The first point displays the identity title **Builder I**. An already repaired part, an out-of-range attempt, or an interaction outside the repair stage grants nothing.

Building mastery does not reduce shared material costs, accelerate placement, strengthen the cottage, or gate any repair action. The repaired home and its rewards remain shared with the room; the personal track only remembers who practiced the craft. Broader free building and higher techniques require their own later design decision.

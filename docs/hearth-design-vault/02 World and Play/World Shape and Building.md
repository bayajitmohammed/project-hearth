---
tags: [game-design, world, building]
---

# World Shape and Building

> [[00 Start Here|Home]] › [[01 Design Guide|Design Guide]] › **02 World and Play** · Next: [[Living World]]

## Physical world

The world is a large, finite 3D continent made from streamed regions. The arrival city, major story sites, and landmark pieces are authored; terrain, smaller settlements, ruins, resources, and local events are assembled procedurally from a world seed.

This gives each group a distinct world while preserving designed characters and memorable places. New outer regions can be added later without promising an infinite world.

The first per-world generation increment assigns a positive saved seed when an offline, LAN-hosted, or dedicated world is first created. Existing saves retain their recorded seed, falling back to the original prototype seed when absent. A creation-only `--world-seed=<positive integer>` option supports reproducible worlds; it never overrides an existing save or backup. The authority publishes the seed to joining clients, which generate matching Northwood scenery; forecasts and daily surveys use the same saved seed. Authored story sites and interaction coordinates remain fixed. This diversifies the existing region without claiming continent streaming or new regions are complete.

## Building and destruction

Players receive a shared homestead and can claim additional wilderness plots. Building uses snap-friendly modular pieces with free decoration and limited terrain shaping.

Players cannot demolish cities, story landmarks, or arbitrary terrain. Wilderness resources regrow, while special changes happen through projects. This keeps freedom manageable, readable, and safe in multiplayer.

The first claimed-plot building proof uses three authored **homestead lantern sockets** after the cottage is repaired. A standing player may spend one shared wood at any empty socket to place a permanent warm trail lantern and earn one normal personal Building mastery point. The placed lantern belongs to the shared world, grants no power or access, never decays, and cannot be built by empty-world catch-up. One player may fill every socket alone, while LAN or dedicated-room companions may divide the work.

These finite sockets prove shared placement, material conservation, persistence, and individual craft credit before the project takes on free positioning, rotation, removal, ownership permissions, or terrain shaping. They are an incremental foundation, not the final building interface.

## First modular furnishing plot

After cottage repair, the shared south yard offers a five-by-three grid of three-metre furnishing cells. Players choose a bench or flower box, aim a nearby preview by moving and looking, rotate it in quarter turns, and explicitly place it for two shared wood. One piece occupies each cell; the authority checks the repaired-home unlock, standing player, plot bounds, reach, vacancy, piece type, rotation, and material balance before accepting a placement. These are decorative furnishings, not barriers or sources of resources.

Any nearby standing companion may remove a furnishing through a separate explicit control, returning its two wood to the shared bag. Placement and removal grant no mastery or milestone rewards, so rearranging the home cannot farm progression. Pieces and rotation persist, old worlds start with an empty furnishing plot, and empty-world time neither places nor removes anything. The original story cottage, lantern sockets, map table, and garden remain outside this plot and cannot be removed. This is the first player-directed modular layout; additional claims, terrain shaping, structural construction, and more furniture remain later depth.

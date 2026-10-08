---
tags: [game-design, world, building]
---

# World Shape and Building

> [[00 Start Here|Home]] › [[01 Design Guide|Design Guide]] › **02 World and Play** · Next: [[Living World]]

## Physical world

The world is a large, finite 3D continent made from streamed regions. The arrival city, major story sites, and landmark pieces are authored; terrain, smaller settlements, ruins, resources, and local events are assembled procedurally from a world seed.

This gives each group a distinct world while preserving designed characters and memorable places. New outer regions can be added later without promising an infinite world.

The first per-world generation increment assigns a positive saved seed when an offline, LAN-hosted, or dedicated world is first created. Existing saves retain their recorded seed, falling back to the original prototype seed when absent. A creation-only `--world-seed=<positive integer>` option supports reproducible worlds; it never overrides an existing save or backup. The authority publishes the seed to joining clients, which generate matching Northwood scenery; forecasts and daily surveys use the same saved seed. Authored story sites and interaction coordinates remain fixed. This diversifies the existing region without claiming continent streaming or new regions are complete.

### Western wilderness — first streaming increment

The next implementation expands the playable footprint west of the home/Northwood corridor into nine contiguous 32-metre sections. Section scenery and a trail-cache location derive from the saved world seed. The client keeps only the local section and its immediate neighbors rendered; each companion streams independently, while world rules never depend on which terrain nodes are loaded. The finite boundary remains authoritative. Authored homes and story sites stay untouched.

Entering a section adds its name to the shared map once and credits the discoverer's normal Exploration mastery. Each section has one persistent personal trail-cache claim: a standing player at the marker can take one provision once, without consuming a companion's claim. Discovery and cache claims never happen during empty-world catch-up. Terrain can unload and regenerate without losing either kind of progress. This first wilderness is peaceful graybox exploration, not final biomes, elevation, continent-scale streaming, or additional settlement simulation.

### Outer western regions — expansion scope

The next world-size increment extends the existing western grid north and west to **36 contiguous 32-metre sections**. The original nine retain their coordinate keys, names, scenery, caches, forage, plots and outpost exactly. New sections use negative grid coordinates rather than shifting established places. The western footprint becomes 192 by 192 metres; the authored home, Northwood, Briarwatch and Reedbank boundaries do not move. Clients still render only their local three-by-three section neighborhood, independently of companions.

The 27 outer sections form seed-derived biome patches: **Pinewoods** offer three daily wood sources, **Bloom meadows** one wood and two herbs, and **Glimmer groves** two wood and one herb. These are distinct graybox vegetation/ground palettes and useful supply choices, not final terrain art, elevation or a complete continent. Original woodland keeps its original two wood/one herb distribution. Every source retains one shared yield per world day, while empty-world time never gathers anything.

Shared discovery, personal one-time trail caches, claim posts, player-built homes and Sera's existing eligibility rules work throughout the larger footprint. Save loading validates against the complete region catalogue, so new discoveries, depletion and negative-coordinate homes survive restart without rewriting old records. The map/journal report the expanded total and local biome, and travel guidance gives both home directions rather than implying every return is due east. Further terrain shaping, roads/route upgrades, generated settlements and continent breadth remain later increments.

## Building and destruction

Players receive a shared homestead and can claim additional wilderness plots. Building uses snap-friendly modular pieces with free decoration and limited terrain shaping.

Players cannot demolish cities, story landmarks, or arbitrary terrain. Wilderness resources regrow, while special changes happen through projects. This keeps freedom manageable, readable, and safe in multiplayer.

The first claimed-plot building proof uses three authored **homestead lantern sockets** after the cottage is repaired. A standing player may spend one shared wood at any empty socket to place a permanent warm trail lantern and earn one normal personal Building mastery point. The placed lantern belongs to the shared world, grants no power or access, never decays, and cannot be built by empty-world catch-up. One player may fill every socket alone, while LAN or dedicated-room companions may divide the work.

These finite sockets prove shared placement, material conservation, persistence, and individual craft credit before the project takes on free positioning, rotation, removal, ownership permissions, or terrain shaping. They are an incremental foundation, not the final building interface.

## First modular furnishing plot

After cottage repair, the shared south yard offers a five-by-three grid of three-metre furnishing cells. Players choose a bench or flower box, aim a nearby preview by moving and looking, rotate it in quarter turns, and explicitly place it for two shared wood. One piece occupies each cell; the authority checks the repaired-home unlock, standing player, plot bounds, reach, vacancy, piece type, rotation, and material balance before accepting a placement. These are decorative furnishings, not barriers or sources of resources.

Any nearby standing companion may remove a furnishing through a separate explicit control, returning its two wood to the shared bag. Placement and removal grant no mastery or milestone rewards, so rearranging the home cannot farm progression. Pieces and rotation persist, old worlds start with an empty furnishing plot, and empty-world time neither places nor removes anything. The original story cottage, lantern sockets, map table, and garden remain outside this plot and cannot be removed. This is the first player-directed modular layout; additional claims, terrain shaping, structural construction, and more furniture remain later depth.

Furnishing mode reserves interaction for placement and suppresses combat, crafting, collection, and provision-use requests from local controls. In particular, R rotates without also performing the normal power strike. Movement, camera control, and world simulation continue; closing the panel immediately restores normal actions. This is input routing, not invulnerability or a pause of the shared world.

### Story keepsakes — implementation increment

The furnishing catalogue connects completed outings to home expression: rekindling Briarwatch unlocks a warm **Watch lantern**, while completing the Moonwell Supper unlocks a dressed **Gathering table**. These recipes belong to the world, including late joiners; they are derived from the existing permanent story outcomes rather than a separate claim or currency. The catalogue shows locked recipes and names their prerequisite. Both use the existing two-wood placement/refund rules, grid and rotation, and grant no mastery, resources, healing, or power. Their authored placeholder shapes are content proofs, not final art. Offline, hosted, and dedicated worlds use the same authority checks and persistent layout.

## Structural building — implementation milestone

The shared south-yard grid expands from decoration into single-storey structural building: each cell may hold one foundation, four independently selected wall/doorway sides, and one roof, alongside its existing furnishing. Every structural piece costs two shared wood and refunds two on explicit removal. Walls and doorways require a foundation; a roof requires a foundation and at least two wall/doorway sides. Remove the roof before reducing its supports below two, and remove supported structure pieces before removing the foundation. Placement and rearrangement never grant mastery or repeatable rewards.

Quarter-turn rotation selects a wall side; a wall and doorway cannot occupy the same side. Doorways have a passable central opening. The authority constrains horizontal movement against wall panels, including their doorway posts, and rejects placement intersecting an active player. Preview and authority use the same support and placement rules. Any nearby standing companion may rearrange the shared structure, so the system is not private ownership or a permanent trap. Existing furnishings retain their saved positions, and authored homes/landmarks remain protected. Multi-storey construction, terrain shaping, additional claims and final architectural art remain separate later work.

## Wilderness settlement — implementation increment

After repairing the cottage, players may establish additional shared homesteads at marked clearings in the western wilderness. Each section except the protected Fartrail Outpost section has one seed-positioned five-by-three plot, kept clear of trees, caches and forage. Explicit interaction at its claim post spends two shared wood once. A claim belongs to the whole world, not its founder; there is no upkeep, passive output, private exclusion or repeatable mastery reward. Claims are permanent in this increment, while individual pieces remain refundable.

Each claimed clearing uses the existing furniture and structural catalogue, costs, rotations, support checks and solid-wall rules. Building mode selects the plot in the player's current section, falling back to the original south yard outside the wilderness. Unclaimed land cannot be built on. Every plot persists independently and renders near the local player; authority checks all walls regardless of what any client has loaded. Companions may claim and build different plots concurrently, and old saves retain their original south-yard layout. Terrain shaping, arbitrary plot positioning, private ownership and multi-storey construction remain deferred.

## Useful homesteads — recovery and preparation

The build catalogue includes a bedroll and a trailwork bench, each using the existing two-wood placement/refund and one-furnishing-per-cell rules. A bedroll provides the cottage's full-health recovery to a nearby standing injured player only while its own cell has a foundation and supported roof. Removing that roof disables recovery without destroying the bedroll or hurting anyone. It does not revive downed players, skip time, set a respawn point or restore companions automatically.

A player-built trailwork bench works outdoors and converts one shared wood plus one shared herb into one personal trail provision through explicit interaction, exactly like the cottage bench. Both stations work in the south yard and claimed wilderness plots, with no mastery farming, upkeep, unattended output or private ownership. If stations are close together, the nearest one is selected deterministically. Visible station labels and prompts explain shelter or material requirements; urgent friend recovery keeps priority.

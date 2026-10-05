---
tags: [game-design, prototype, roadmap]
---

# Prototype and Vertical Slices

> [[00 Start Here|Home]] › [[01 Design Guide|Design Guide]] › **04 Production** · Active test: [[Cumulative Slices 1-6 Playtest Checklist]]

## Use this note

- [[#Playable slices|Roadmap table]]
- [[#Current implementation handoff|Current implementation handoff]]
- Implementation records: [[#Slice 1 build order|Slice 1]] · [[#Slice 2 — first cumulative increment|Slice 2]] · [[#Slice 3 — first cumulative increment|Slice 3]] · [[#Slice 4 — first cumulative increment|Slice 4]] · [[#Slice 5 — first cumulative increment|Slice 5]] · [[#Slice 6 — first cumulative increment|Slice 6]]
- [[Cumulative Slices 1-6 Playtest Checklist|Temporary cumulative playtest checklist]]

## Smallest fun prototype

A 1–4 player build contains one city street, one shared homestead, one small generated forest, one NPC, one creature, one request, basic gathering/building, and persistence. Its exact scope is [[First Vertical Slice]].

The test is successful if players help each other naturally, cause one remembered world change, and want to return to the same save. Visual polish, large content libraries, PvP, Discord, and offline simulation are excluded.

## Playable slices

| Slice | Playable promise           | Adds                                                                          | Ship to                 |
| ----: | -------------------------- | ----------------------------------------------------------------------------- | ----------------------- |
|     0 | **Multiplayer proof**      | Windows, browser, and Android join one room; movement, interaction, save/load | Internal testers        |
|     1 | **A New Home**             | Arrival street, cottage, forest, gather/craft/build, one request              | Friends-and-family test |
|     2 | **A Place That Remembers** | NPC routines, reputation, shared projects, chronicle, local event             | Closed alpha            |
|     3 | **Beyond the Road**        | Generated regions, mapping, travel upgrades, ruin, combat, failure loop       | Public demo             |
|     4 | **Choose a Life**          | Farming, cooking, craft, trade, mastery tracks, settlement needs              | Closed beta             |
|     5 | **Our Shared World**       | 2–8 scaling, drop-in/out, dedicated server, catch-up, recovery tools          | Early Access            |
|     6 | **Gather and Celebrate**   | Festivals, party activities, normalized PvP, launch content and polish        | Version 1.0             |

Each slice remains playable and becomes part of the next build. A slice ships only when its named promise works end-to-end in multiplayer, survives save/load, and passes a fresh-player playtest. These are test stages and updates to one game—not separate products.

## Working verification cadence

During the cumulative implementation pass, every change receives automated coverage and is tested in the exported desktop Web build through Playwright CLI first. Broader runtime validation then proceeds to Windows desktop and native Android; native Mac is supplementary. Linux deployment packaging is deferred and does not block current slice work. Repeated fresh-player tests and full Web, Android, and Windows runtime passes are deferred until the cumulative game has taken enough shape for those tests to produce meaningful feedback.

Until that later validation pass, completing a slice means its smallest promised systems are implemented cumulatively; it does **not** mean the slice has passed its final ship gate. Fresh-player understanding and all-target runtime compatibility remain required before release.

## Current implementation handoff

- Content-first continuation: prioritize new playable places, resident stories, and activities now that the minimum base logic exists. Keep checks focused; interrupt content work for regressions that block play, corrupt saves, or break offline/co-op. Fresh-player and full-device release gates remain deferred, not waived.
- Reedbank Hollow: an authored eastern Northwood branch now contains Oren's **The Wind Returns** story. Companions may split the conversation, northern reed-bed sail recovery, two-wood mill repair, and return. Completion leaves turning sails, a lit recovery shelter, and one shared chronicle/morale/reputation consequence; finder and builder keep their own mastery credit. Version-26 saves retain every step, and older worlds begin with the untouched mill. Focused state/presentation and play-mode checks, the full world-state suite, and simultaneous two-client handoff pass. Exported-Web Chromium completed the whole chain with conserved wood and no console errors or warnings. This remains authored graybox content, not final art or streamed continent generation.
- Project: `/Users/kyrin0/Desktop/studio/garage/project-hearth`
- Current checkpoint: the minimum cumulative Slice 6 promise, **Gather and Celebrate**, is implemented through the in-world Hearthlight Festival, explicit 1–8 player enrollment, a normalized checkpoint circuit, authoritative results, and persistent cosmetic ribbons.
- Post-slice foundation: the startup flow now offers separate offline, native LAN-hosted, and join-room paths. Offline and LAN saves remain separate, while all modes use the same authoritative world rules. A focused headless test, a native host-plus-guest probe, and exported-Web offline movement pass verify the foundation; broader device validation remains deferred.
- Persistence hardening: every world mode now writes through a temporary file, retains one previous valid checkpoint, and automatically falls back to that backup when the primary save is missing or unreadable.
- Slice 4 depth: after the produce stall opens, each new world day regrows the shared moonroot garden and posts one forecast-responsive fresh-produce or cooked-stew request. Contributions retain personal mastery credit, while completion adds one bounded pantry provision without replaying milestone rewards.
- Mastery depth: tier-II Farming, Cooking, and Trade techniques batch only eligible nearby/prepared work, preserve per-unit credit, and leave every base action available to newcomers.
- Home recovery depth: the repaired cottage is a personal safe recovery point. Standing injured players may rest to recover fully without advancing time or affecting companions; downed and field recovery rules remain distinct.
- Cooperative recovery depth: a prepared standing player may spend one carried trail provision to restore one health to a nearby injured friend; downed friends still require revival.
- Cooperative inventory depth: a standing player may hand one trail provision to the nearest nearby healthy friend after urgent recovery and valid world interactions have had priority. Transfers conserve personal inventory and grant no progression or currency.
- Shared-storage depth: the repaired cottage has an eight-fish creel. Players may store personal riverfish for another cook to turn into a personal trail provision later; stock is conserved, persistent, and inert while the room is empty.
- Gathering-and-crafting depth: after cottage repair, authored forest wood and herb nodes renew once per world day, and a nearby player may spend one of each shared material at the cottage trailwork bench for one personal trail provision. Empty time exposes only the current forage and never gathers or crafts it.
- Claimed-plot building depth: three authored homestead sockets accept one shared wood each for a permanent warm lantern and personal Building credit. Version-20 persistence and migration keep the bounded multiplayer placements durable before free-position modular construction.
- Returning-player depth: the repaired cottage Chronicle Board preserves an independent read position for each identity. Unread shared outcomes appear as a concise return summary, the full history remains reviewable at the board, and one player acknowledging entries never clears them for companions.
- Combat pacing depth: each successful basic attack begins a short per-player authoritative recovery, preventing input spam without coupling companions or granting progression power.
- Alternate combat depth: every newcomer can trade speed for impact with a two-damage Power Strike whose longer personal recovery keeps its sustained damage below repeated basic attacks.
- Defensive combat depth: a timed per-player brace blocks one incoming creature hit, is consumed on contact, and uses a short personal cooldown without granting progression power.
- Loadout depth: the repaired-home gear rack lets every player freely switch between balanced Vanguard timing and a Guardian trade-off with easier bracing but slower attack recovery; the personal choice persists without gating actions or damage.
- Cooperative loadout depth: a nearby standing Guardian can spend an active brace to intercept one telegraphed hit for a companion. Self-brace resolves first, and deterministic distance and identity ordering keep all authoritative play modes consistent.
- Livelihood breadth: Willowmere Pond now provides the first independent timing-based fishing loop. Version-15 persistence remembers personal catches and Fishing identity but never resumes transient casts; successful fish can be cooked into one personal trail provision without passive catch-up or coin generation. Focused state, readability, touch, and simultaneous two-client checks pass.
- Combat readability depth: forest-creature and ruin-guardian strikes name a target during a short authoritative wind-up, giving that player time to brace or leave range while companions keep acting.
- Encounter-boundary depth: authored enemies stop pursuing players beyond their home area, return visibly, and recover only after reaching spawn so danger cannot be dragged through peaceful spaces.
- Repeatable combat depth: defeating the ordinary forest creature makes the area safe for the current world day, then the next day renews that encounter without reviving the one-time ruin guardian.
- Relationship depth: Mara remembers meaningful story conversations and one optional daily check-in per player, displaying personal rapport without gating any shared quest or reward.
- Relationship milestone depth: reaching three personal Mara rapport awards one persistent Woven Hearth Charm, visible to its owner and companions but granting no power or private access.
- Resident-story breadth: restoring the Old Stone Ruins route brings mapmaker Nima to the neighborhood. Players may split her conversation, Northwood field-case recovery, and return across sessions; completion makes her a scheduled resident, leaves a persistent map table, and records the shared consequence while personal rapport remains individual.
- Landmark-story breadth: Nima's completed map table reveals Moonwell Glade. Players may split its reveal, discovery, and three stone attunements across sessions; completion leaves a luminous shared sanctuary and safe standing-player recovery point without timers, exclusive access, or empty-world progression.
- Cross-livelihood content: after the produce stall and Moonwell are complete, three conserved moonroot-and-riverfish courses create a persistent Moonwell Supper. Personal or creel fish support asynchronous cooperation, cooks keep normal mastery credit, and completion leaves one shared gathering table and chronicle consequence.
- Moonwell Supper verification: state and presentation checks pass, including version-23 migration and partial-progress persistence. A simultaneous two-client probe verifies personal-fish priority, shared-creel fallback, individual cook credit, and one shared consequence. A focused exported-Web Chromium pass verifies all three courses, ingredient counts, the dressed table, and saved completion with no browser errors or warnings. Full platform validation remains deferred.
- Garden continuity: filling a market request no longer hides or locks remaining ripe moonroot. Surplus crops remain available for the supper or later requests, with the same per-plot harvest persistence and daily renewal. State and presentation checks plus a focused exported-Web Chromium pass verify one conserved harvest after market completion, normal Farming credit, unchanged market rewards, and no duplicate crop on repeated interaction.
- Modular furnishing: the repaired homestead opens a shared south-yard grid for player-positioned benches and flower boxes, quarter-turn rotation, and explicit removal with conserved wood refunds. Version-25 layouts persist; automated authority/persistence/preview checks, offline save/load, simultaneous contested-placement probes, and exported-Web keyboard placement/rearrangement pass. The browser pass also reproduced a pre-existing packet-buffer overflow during event-loop stalls; transport follow-up is tracked separately from furnishing behavior.
- Browser transport follow-up: a saved three-by-1.2-second event-loop-stall regression reproduced incoming snapshot overflow (45 errors) with the default receive buffer. Changing only client inbound byte capacity to a bounded 1 MiB made the same regression pass with zero errors; a full connected Chromium session and two-client furnishing regression also remained clean. Long suspension and production snapshot scaling remain outside this focused proof.
- Furnishing cursor follow-up: build mode releases the pointer and requires a right-mouse drag to turn the view. A camera regression and exported-Web button-driven removal, rotation, placement, and closing pass; the final browser session has no errors or warnings. Keyboard and mouse workflows are verified; broader controller and native-device usability remain deferred.
- Furnishing input isolation: rotation no longer also triggers the normal power strike. Local and connected control paths suppress combat, crafting, collection, and provision actions while furnishing, and hide ordinary context prompts. The reproducing local-authority regression passes, including normal combat after exit. Chromium confirms rotation, conserved crafting materials while open, and normal crafting after closing, with no console errors.
- Per-world generation: new worlds receive a persistent random seed or creation-only explicit seed. Existing saves and recovered backups retain their original seed. Authority snapshots synchronize Northwood generation, while forecasts and survey rotation use the same saved value. Deterministic-layout, legacy fallback, offline creation/backup, and simultaneous two-client checks pass; exported-Web Chromium renders seed 112358 and discovers Northwood without console errors. Authored sites remain fixed; continent streaming and broader procedural content are still pending.
- Economy depth: accepted market units pay their individual contributor one persistent coin each, and a separate supply basket exchanges two coins for one personal trail provision without replacing free pantry stock.
- Local-supply depth: the coin basket holds three shared provisions per world day. Purchases consume conserved stock, a new day resets rather than stacks it, and empty time never buys or multiplies goods.
- Shared-project depth: after the stall opens, players may contribute personal coin one unit at a time toward a persistent four-coin Hearthbloom planter that changes the homestead without granting power or requiring companions.
- Combat identity depth: successful damaging attacks build personal Combat mastery and display a Warden title, while all combat statistics and base actions remain identical for newcomers.
- Exploration identity depth: the player who reveals a new shared place builds personal Exploration mastery and displays a Pathfinder title, while the discovery and all routes remain shared with newcomers.
- Repeatable exploration depth: after route restoration, one deterministic Northwood survey marker rotates each world day and remains individually recordable by every player without passive or exclusive map progress.
- Building identity depth: successful cottage-part placements build personal Building mastery and display a Builder title, while repair costs, actions, and the finished home remain shared with newcomers.
- Living-world atmosphere: the authoritative day selects one deterministic safe forecast shared by every mode, while clients render the clock as readable day/night ambience. Renewable food orders respond to that forecast without adding punitive weather effects.
- Verified on Mac: native client, desktop Web, and Android emulator can connect, move, collect once, and retain state.
- Windows: the exported x86-64 build runs, connects to the Mac server, and displays both Windows and Mac players.
- Mac and Windows have been used together for the multiplayer quest loop, reconnection, persistence, movement, and camera checks.
- Deferred validation: fresh-player usability and full Web, Android, and Windows runtime passes.
- Historical focused Mac check: the active Slice 4 need and completed stall were inspected in first- and third-person presentation; overlapping garden labels, an oversized cumulative chronicle, and a spawn-crowding waystone were corrected. Browser-first Playwright checks now replace native Mac as the working presentation gate.
- Focused desktop Web check: the Slice 5 HUD, room connection, WASD movement, camera toggle, pantry transfer, downed return, and recovery-pack prompt/label pass in Chromium through the exported build with no console errors. Synthetic pointer-lock mouse motion was not treated as a mouse-look validation.
- Cumulative exported-Web check: a fresh-world Chromium journey passes through cottage repair, Welcome Lights, shared discovery, repeated solo guardian failure/return, eventual waystone restoration, the livelihood loop, empty-room sleep, reconnect catch-up, and pantry pickup. A non-blocking pointer-lock document message appeared only in the persistent-profile Playwright harness; focused gameplay runs and camera regression coverage remain clean.
- Active completion work: follow [[Cumulative Slices 1-6 Playtest Checklist]] with a fresh player, then complete the full desktop Web, Windows, and native Android runtime pass. Archive the durable result here before deleting the temporary checklist.
- Current work continues content expansion under the user's content-first direction; later fresh-player feedback will guide broader usability and launch polish.

## Slice 5 — first cumulative increment

The smallest proof of **Our Shared World** begins after the neighborhood produce stall opens:

1. One authoritative room admits up to eight distinct persistent player identities. Players may join, leave, and reconnect without resetting shared objectives or creating a second active copy of the same identity.
2. The active player count is visible, while existing shared-project rules continue to credit the player who performs individual mastery work.
3. When the room becomes empty, the world records that it went to sleep. On the first return, elapsed real time produces at most three pantry provisions at the completed produce stall. This catch-up is deliberately bounded and can never damage or decay the world.
4. A player can take one personal trail provision from the pantry. These provisions are gathered expedition materials, not gear or permanent progression.
   A standing injured player may consume one provision to restore one health; it cannot self-revive or exceed maximum health.
   A standing player may instead spend one carried provision to restore one health to a nearby injured, non-downed friend.
   At the repaired cottage, a standing injured player may instead rest to recover fully without consuming a provision, advancing time, or interrupting companions.
5. Returning to safety while downed leaves carried trail provisions in one persistent recovery pack at the defeat location. The owner or a friend can recover the pack for its owner, and the pack survives disconnects and server restarts.
6. The existing headless authoritative room remains the server proof. Linux deployment packaging, multi-room process management, and hosting infrastructure are deferred while browser, Windows desktop, and Android client quality take priority.

The prototype uses a short catch-up interval so the behavior can be tested during development. Production calendar rates, accounts, multi-room process management, autoscaling, and encounter-content scaling remain later work. The uninterrupted cumulative Slice 3–5 desktop Web journey remains a required validation gate and is not considered passed by focused or automated Slice 5 coverage.

### Implementation progress

- [x] Eight-player room capacity, distinct active identities, and visible online count
- [x] Persistent bounded pantry catch-up after an empty-room sleep
- [x] Personal trail provisions and persistent friend-recoverable packs
- [x] Server-authoritative provision use on keyboard, controller, and touch
- [x] Server-authoritative field aid for nearby injured friends
- [x] Personal full-health recovery at the repaired cottage
- [x] Version-7 persistence and version-6 migration
- [x] Automated state, migration, presentation, two-client regression, and eight-client capacity coverage
- [x] Focused exported desktop Web functionality and visual check in Chromium
- [x] Exported desktop Web functionality and visual check of the cumulative Slice 3–5 journey
- [ ] Deferred validation: fresh-player playtest of the cumulative game
- [ ] Deferred validation: full Desktop Web, Android, and Windows runtime pass

## Slice 6 — first cumulative increment

The smallest proof of **Gather and Celebrate** begins after the neighborhood produce stall opens:

1. The successful food project opens the **Hearthlight Festival** at the existing neighborhood gathering place, so the social activity belongs to the shared world rather than a separate lobby.
2. One to eight players explicitly opt into the **Hearthlight Circuit**, a short route through three ordered festival checkpoints. A joined player starts the run with a second interaction at the festival arch, giving friends a clear window to join while preserving solo play.
3. The authoritative room owns enrollment, ordered checkpoint progress, and the first finisher. Players who did not opt in cannot advance or affect the result.
4. The standard circuit uses the shared movement rules for every entrant; gear, mastery, provisions, and playtime grant no advantage. This is the first normalized, opt-in competitive activity and introduces no hostile open-world PvP.
5. Every finisher receives one persistent cosmetic festival ribbon. The winner is named in the result, but ribbons grant no power and the activity can be replayed.
6. Completing the circuit for the first time raises neighborhood morale and reputation, leaves persistent festival decorations at the gathering place, and records the celebration in the shared chronicle.
7. Completed festival history and personal ribbons survive reconnects and server restarts. An interrupted signup or race safely returns to enrollment after a server restart; production scheduling, seasons, activity matchmaking, combat arenas, chaos-mode gear, and launch-content breadth remain future work.

This is the minimum cumulative Slice 6 implementation, not the final Version 1.0 content and polish pass. Its purpose is to prove that friends can discover, opt into, complete, and replay one fair social activity inside the persistent world. Fresh-player usability and full Windows, desktop Web, and Android runtime validation remain release gates.

### Implementation progress

- [x] Server-authoritative festival enrollment, ordered circuit, winner, and replay flow
- [x] Persistent first-completion world change and per-player cosmetic ribbons
- [x] Version-8 persistence and version-7 migration
- [x] In-world festival arch, checkpoints, objective guidance, and interaction prompts
- [x] Automated state, migration, presentation, legacy regression, and simultaneous two-client coverage
- [x] Focused exported desktop Web functionality and visual check in Chromium
- [ ] Deferred validation: fresh-player playtest of the cumulative game
- [ ] Deferred validation: full Desktop Web, Android, and Windows runtime pass

## Slice 3 — first cumulative increment

The smallest current proof of **Beyond the Road** begins after Welcome Lights:

1. Players follow the existing ruins rumor north into a deterministic seed-derived region beyond the original forest boundary.
2. Entering Northwood and reaching the Old Stone Ruins reveals both locations for the whole room on a shared map.
3. A ruin guardian creates a server-authoritative first-journey combat obstacle using the existing attack, downed, and cooperative-revive rules.
   Successful basic attacks use a short per-player recovery window; missed or out-of-range inputs do not consume it.
   A standing player may time a short brace to block one incoming hit; brace availability and cooldown are personal, so companions remain independent.
4. A downed solo player may return safely to the cottage; equipped gear and permanent progression remain untouched. Recoverable expedition packs remain deferred until expedition inventory exists.
5. Defeating the guardian lets the group restore an ancient waystone. The persistent route makes repeat travel between home and the ruins immediate.
6. The restored route grants reputation and enters the shared chronicle.

This is a deliberately small proof of region generation, shared discovery, an authored destination, first-journey danger, safer failure, and improved repeat travel. It does not introduce continent streaming, production procedural generation, a large combat system, or full expedition inventory.

### Implementation progress

- [x] Seed-derived Northwood region and authored Old Stone Ruins destination
- [x] Server-authoritative shared map discovery and ruin guardian state
- [x] Independent server-authoritative basic-attack recovery timing
- [x] Timed server-authoritative brace with keyboard, controller, and touch access
- [x] Persistent waystone activation and two-way fast travel
- [x] Solo return-to-safety extension of the existing downed/revive loop
- [x] Version-5 persistence and version-4 migration
- [x] Automated state, migration, presentation, and legacy regression coverage
- [x] Two-client networking regression
- [x] Exported desktop Web functionality and visual check of the cumulative journey
- [ ] Deferred validation: fresh-player playtest of the cumulative game
- [ ] Deferred validation: full Desktop Web, Android, and Windows runtime pass

## Slice 4 — first cumulative increment

The smallest proof of **Choose a Life** begins after the Old Stone Ruins waystone is restored:

1. The neighborhood posts one visible food need at the gathering place.
2. Players harvest four persistent cottage-garden plots. Each harvest contributes moonroot to the shared project bag and grants Farming mastery to the player who tended it.
3. At the cottage cookfire, a player turns two moonroot into one hearth stew. Cooking grants that player Cooking mastery.
4. At the neighborhood market crate, a player delivers two stews. Each delivery grants that player Trade mastery and advances the shared settlement need.
5. Fulfilling the need opens a persistent produce stall, improves neighborhood morale and reputation, and records the result in the chronicle.
6. Each mastery track displays the individual player's contribution and first title, allowing friends to divide the work or one player to complete the whole loop.

This is a deliberately small proof that farming, cooking, trade, individual mastery, and a shared settlement need form one readable loop. Crop timers, planting choices, recipe libraries, direct player trade, coin, bounded market simulation, and production chains remain future Slice 4 depth. The first titles are identity feedback, not the final mastery progression or functional cap.

The first post-slice depth increment makes the livelihood loop renewable without introducing those larger systems: the next in-game day after the stall opens begins one daily market request and regrows all four plots. Clear weather asks for three fresh moonroot, gentle rain asks for two hearth stews, and overcast days use day parity to choose between them, so the forecast visibly frames different parts of the short production chain. Completing either request adds one provision to the bounded pantry. Missed days do not stack requests or rewards, and the daily loop does not repeat the stall-opening reputation, morale, or chronicle outcome.

### Implementation progress

- [x] Server-authoritative garden, cooking, delivery, and settlement-need state
- [x] Per-player Farming, Cooking, and Trade mastery
- [x] Persistent produce stall, morale/reputation result, and chronicle entry
- [x] Version-6 persistence and version-5 migration
- [x] In-world stations, objective guidance, interaction prompts, and mastery display
- [x] Renewable daily garden and settlement-order loop with bounded pantry output
- [x] Forecast-responsive daily order selection with readable rationale
- [x] Automated state, migration, presentation, and legacy regression coverage
- [x] Two-client networking regression, including the complete livelihood loop
- [x] Exported desktop Web functionality and visual check of the cumulative journey
- [ ] Deferred validation: fresh-player playtest of the cumulative game
- [ ] Deferred validation: full Desktop Web, Android, and Windows runtime pass

## Slice 2 — first cumulative increment

The smallest current proof of **A Place That Remembers** begins when the cottage repair is complete:

1. The repaired home creates a chronicle entry and unlocks a local welcome event.
2. Mara invites the players, then moves from the cottage to the neighborhood gathering place.
3. Players collectively light three welcome lanterns; every contribution is shared and persistent.
4. Completion improves neighborhood morale and reputation, leaves the lanterns visibly lit, and adds the celebration to the chronicle.
5. Version-3 Slice 1 saves migrate into the invitation rather than losing or replaying the cottage outcome.

This is the minimum cumulative Slice 2 implementation, not the final production-scale simulation. Time-based schedules, a general event director, multiple NPC relationships, and reusable settlement-condition rules remain future depth to add only when later slices need them.

### Implementation progress

- [x] Server-authoritative event, shared lantern project, morale, Mara routine state, and chronicle
- [x] Version-4 persistence and version-3 migration
- [x] In-world markers, lit results, objective guidance, and visible shared chronicle
- [x] Automated state, migration, readability, and legacy regression coverage
- [x] Two-client Slice 1 networking regression
- [x] Desktop Web, Android, and Windows debug exports rebuild successfully
- [x] First depth increment: persistent neighborhood clock, bounded calendar catch-up, and Mara's readable post-event routine
- [x] Second depth increment: shared daily forecast, readable daylight, and non-punitive weather ambience
- [ ] Deferred validation: fresh-player playtest of the cumulative game
- [ ] Deferred validation: full Desktop Web, Android, and Windows runtime pass

## Slice 1 build order

1. Replace the networking test arena with the graybox arrival street, cottage, and forest boundary.
2. Add Mara and the shared repair-cottage request.
3. Add gathering, one inventory, one repair-kit recipe, and three persistent placements.
4. Add one creature, health, defeat, and cooperative revive.
5. Persist the cottage, inventory, reputation, quest state, and Mara's response.
6. Add the map rumor and clear first-time guidance.
7. Test the complete loop on Mac native, desktop Web, and Android throughout development.
8. When the loop is playable, test the exported build on Windows and diagnose platform-specific issues there.
9. Run a fresh 1–4 player playtest and check every item in [[First Vertical Slice#Done when]].

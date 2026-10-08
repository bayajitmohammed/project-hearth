# Project Hearth

Godot prototype for the multiplayer world game. Slice 0 proves authoritative networking and persistent shared state across Windows, desktop Web, and Android clients. The cumulative build now includes the minimum implementations of Slice 1, **A New Home**, Slice 2, **A Place That Remembers**, Slice 3, **Beyond the Road**, Slice 4, **Choose a Life**, Slice 5, **Our Shared World**, and Slice 6, **Gather and Celebrate**.

## Run locally on macOS

**Moonweaver magic:** restoring Moonwell adds a third free kit to the home gear rack's **E** cycle. **Space** casts guided Moonthread for one damage and **R** casts Woven Burst for two, reaching 5.5 metres with twice Vanguard's attack recovery. **F** provides a shorter brace; this kit cannot intercept for friends. Cast from inside the enemy's home area; returning enemies and solid built walls reject casts, while doorway openings allow them. Health, movement and per-action mastery are unchanged, and sparring retains equal rules. The chosen kit uses existing persistence; shared light traces are transient. The **Moonwell's Thread** journal entry explains the new option. These are automatic-targeted tethers, not aimed projectiles.

Magic coverage: `Godot --headless --path . --script res://tests/test_moonweaver.gd`. Copy `tests/fixtures/moonweaver_ready_world.json` to an isolated save, serve room `MAGIC` on port `9488`, and launch `tests/moonweaver_multiplayer_probe.gd` twice with `--connect=ws://127.0.0.1:9488 --room=MAGIC` and identities `--player-token=magic-a` / `--player-token=magic-b`. For the browser path, join a fresh copy, visit the home rack, cycle twice from Vanguard, then approach the forest creature and use Space/R.

**Neighborhood visits:** find **The Market Green** in the journal and on the east edge of the market. An open produce stall plus rain or a restored Fartrail Outpost invites **Travelers' Rest** (two shared wood and two personal provisions); Sera's completed welcome invites **Seedkeepers' Exchange** (two shared herbs and two shared moonroot). Use **E** at either job marker to contribute one ingredient. The director prefers less-completed eligible visits, keeps one outstanding visit without a deadline, and waits until a later world day after completion. First completions leave a permanent canopy or seed garden and one shared milestone; repeats add only a provision when the pantry has room. Version-38 saves retain partial visits. Empty-world time never performs event jobs or queues missed visits.

Visit coverage: `Godot --headless --path . --script res://tests/test_neighborhood_visits.gd`. Copy `tests/fixtures/neighborhood_visit_ready_world.json` to an isolated save, serve room `VISIT` on port `9485`, and launch `tests/neighborhood_visit_multiplayer_probe.gd` twice with `--connect=ws://127.0.0.1:9485 --room=VISIT` and identities `--player-token=visit-a` / `--player-token=visit-b`. For browser walkthroughs, the same fixture provides two pantry provisions for a fresh identity; `tests/fixtures/seed_exchange_ready_world.json` supplies the second visit's conditions and ingredients.

**Direct trading:** press **Y** or **Trade** near a standing companion. Choose personal coin, riverfish or trail provisions and 1–99 units on each side, then send the exact exchange. Only the named recipient can accept; either player can decline/cancel. Goods move together only after authority rechecks both inventories and three-metre proximity. Offers expire after 60 seconds and cancel on departure, downing or insufficient promised goods. Shared materials, gear and mastery are never traded. Pending offers are not saved; completed balances are. Closing the panel leaves the offer pending until cancelled or expired.

Trade coverage: `Godot --headless --path . --script res://tests/test_personal_trades.gd`. Copy `tests/fixtures/personal_trade_ready_world.json` to an isolated save, serve room `TRADE` on port `9483`, and launch `tests/personal_trade_multiplayer_probe.gd` twice with `--connect=ws://127.0.0.1:9483 --room=TRADE` and identities `--player-token=trade-a` / `--player-token=trade-b`. The probe's `--browser-companion` mode accepts one browser offer and proposes another; a fresh browser identity can earn two coins by delivering the fixture's two prepared stews before returning to spawn to trade.

**Sera's Welcome:** a western claim with a sheltered bedroll and cookhearth attracts Sera the seedkeeper. Find her beside that claim's entrance, speak with **E**, then contribute two personal trail provisions across any companions or sessions. The welcome leaves a permanent awning and one shared chronicle/morale/reputation outcome. Rearranging furniture never evicts her. Afterward each player may check in once per world day for personal rapport, without power or passive rewards. Version-37 saves retain partial welcomes; older qualifying layouts start with her invitation. The shared map and **Sera's Welcome** journal entry identify her homestead.

Guest coverage: `Godot --headless --path . --script res://tests/test_homestead_guest.gd`. Copy `tests/fixtures/homestead_guest_ready_world.json` to an isolated save, serve room `GUEST` on port `9481`, and launch `tests/homestead_guest_multiplayer_probe.gd` twice with `--connect=ws://127.0.0.1:9481 --room=GUEST` and identities `--player-token=guest-a` / `--player-token=guest-b`. The browser fixture includes a stocked bread recipe at Westwind's oven so a fresh identity can prepare both welcome provisions.

**Homestead kitchens:** build a **Cookhearth** after cottage repair, or a **Grain mill** and **Bread oven** after restoring Oren's mill. Each costs/refunds two wood in any shared plot. Outside B mode, **E** at a cookhearth prepares requested stew before fish, using the cottage's existing recipes and mastery rules. The mill converts two shared sunwheat into one flour; the oven uses one flour and herb for two personal provisions. These stations complete the player-built farm-to-food loop without passive production. The journal's **A Kitchen of Your Own** entry explains the recipes. Existing version-36 layouts persist the new pieces.

Kitchen coverage: `Godot --headless --path . --script res://tests/test_homestead_kitchens.gd`. Copy `tests/fixtures/homestead_kitchen_ready_world.json` to an isolated save, serve room `KITCHEN` on port `9479`, and launch `tests/homestead_kitchen_multiplayer_probe.gd` twice with `--connect=ws://127.0.0.1:9479 --room=KITCHEN` and identities `--player-token=kitchen-a` / `--player-token=kitchen-b` to verify a farmer/cook handoff.

**Homestead farming:** the restored ruins route unlocks **Moonroot bed**, and Oren's restored mill unlocks **Sunwheat bed** in the B/T build catalogue. Each costs two refundable wood at home or in a wilderness claim. Outside build mode, **E** plants reusable seeds; after 120 world minutes, **E** harvests one shared moonroot or two shared sunwheat and credits the harvester's Farming mastery. Crops stay ripe until harvested; another interaction replants. Removing a bed discards its planting, as the build-panel warning explains. Version-36 saves preserve growth, while empty time never harvests or replants.

Farming coverage: `Godot --headless --path . --script res://tests/test_homestead_farming.gd`. Copy `tests/fixtures/homestead_farming_ready_world.json` to an isolated save, serve room `FARM` on port `9477`, and run `tests/homestead_farming_multiplayer_probe.gd` twice with `--connect=ws://127.0.0.1:9477 --room=FARM` and identities `--player-token=farmer-a` / `--player-token=farmer-b` to verify contested harvest conservation.

**Opt-in sparring:** opening the produce stall unlocks the south-east training circle. Two players explicitly volunteer with **E** at its sign; either can leave the circle to cancel without loss. After a three-second countdown, **Space/R** taps remove one of three separate match pips, and **F** guards one tap during a half-second window. Everyone uses the same reach and cooldowns regardless of gear or mastery. A decisive finish awards both volunteers one cosmetic sparring ribbon; timeouts award none. World health, inventory and mastery are untouched. Version-35 saves retain ribbons and the last winner, never an interrupted bout. Offline solo play does not require this optional two-player activity.

Sparring coverage: `Godot --headless --path . --script res://tests/test_sparring.gd`. Copy `tests/fixtures/sparring_ready_world.json` to an isolated save, serve room `SPAR` on port `9475`, and run `tests/sparring_multiplayer_probe.gd` simultaneously with `--connect=ws://127.0.0.1:9475 --room=SPAR` and identities `--player-token=spar-a` / `--player-token=spar-b`. For a browser bout, the probe accepts `--browser-companion` with identity `spar-b` and volunteers after the browser player signs up.

**Briarwatch pressure waves:** one standing traveler in the clearing draws one locked ground mark; groups of 2–4 draw two, and 5–8 draw three. All marks give the same 1.2-second warning. Leave the circles or time a brace; overlapping circles can hit you only once per wave. New waves adapt to arrivals/withdrawals without resetting broken bindings or increasing health/rewards. Empty clearings cancel pending danger, and waves are never saved.

Scaling coverage: `Godot --headless --path . --script res://tests/test_briarwatch_scaling.gd`. Use an isolated copy of `tests/fixtures/briarwatch_pressure_ready_world.json`, room `PRESSURE` on port `9473`, and simultaneous `tests/briarwatch_pressure_probe.gd` clients with `--connect=ws://127.0.0.1:9473 --room=PRESSURE` and identities `--player-token=pressure-a` / `--player-token=pressure-b`. For a browser companion in a separate room, the same probe accepts `--browser-companion` and defends for four minutes.

**Useful homesteads:** the build catalogue now includes **Bedroll** and **Trailwork bench**, each costing/refunding two wood. Outside build mode, **E** at a bedroll restores a standing injured player only when its cell has a foundation and supported roof. Removing the roof disables rest. At a player-built bench, **E** consumes one shared wood and one herb for one personal provision. These work at home and in wilderness claims without passive output, mastery rewards, time skips, or respawn changes.

Station coverage: `Godot --headless --path . --script res://tests/test_useful_homesteads.gd`. For concurrent rest/crafting, copy `tests/fixtures/useful_homesteads_ready_world.json` to an isolated save, serve room `STATIONS` on port `9471`, and launch `tests/useful_homesteads_multiplayer_probe.gd` simultaneously with `--connect=ws://127.0.0.1:9471 --room=STATIONS` and identities `--player-token=station-a` / `--player-token=station-b`.

**Wilderness homesteads:** after cottage repair, each western section except the Fartrail Outpost section offers a marked clearing. Press **E** at its post to claim the shared plot for two wood once. Use **B** nearby to build with the same furniture, foundations, walls, doorways and roofs as the south yard. Claims belong to the group, persist independently in version-34 saves, and never decay or generate passive goods. Buildings stream with nearby sections while their collision stays authoritative. Unclaimed land, caches, forage and authored landmarks remain protected.

Plot coverage: `Godot --headless --path . --script res://tests/test_wilderness_plots.gd`. Use an isolated copy of `tests/fixtures/wilderness_plots_ready_world.json`, serve room `PLOTS` on port `9469`, and run `tests/wilderness_plots_multiplayer_probe.gd` simultaneously with `--connect=ws://127.0.0.1:9469 --room=PLOTS` and identities `--player-token=plot-a` / `--player-token=plot-b`.

Western sections now contain **two wood piles and one herb patch each**. Use **E** nearby to gather one shared material. Sources renew on the next world day, with saved room-wide depletion and no unattended harvesting. These materials feed existing building, outpost, cooking and trailcraft recipes.

Forage coverage: `Godot --headless --path . --script res://tests/test_wilderness_forage.gd`. Use an isolated copy of `tests/fixtures/wilderness_forage_ready_world.json`, serve room `FORAGE` on port `9465`, and run `tests/wilderness_forage_multiplayer_probe.gd` simultaneously with `--connect=ws://127.0.0.1:9465 --room=FORAGE` and identities `--player-token=forage-a` / `--player-token=forage-b` to check competing harvests.

**Fartrail Outpost** is a seed-located wilderness project. Its journal entry appears after entering the western trails and names its section and direction from home. Complete three independent jobs with **E**: shelter (3 shared wood), remedies (2 shared herbs), and a meal (2 fish, using personal stock before the shared creel). Completion permanently opens separate rest and trailcraft stations and records one shared outcome. Partial work survives saves and terrain unloading.

**The Way Home:** after Fartrail and the ruins waystone are complete, the outpost's north sign accepts a three-wood frame and a two-herb binding, one affordable unfinished job per **E**. The finished route links that sign to the western home post for free two-way travel. Only the interacting standing player moves; travel does not heal, award rewards or consume provisions. Version-39 saves retain partial construction and the shared route. Focused coverage: `Godot --headless --path . --script res://tests/test_fartrail_route.gd`. For two-client coverage, copy `tests/fixtures/fartrail_route_ready_world.json` to an isolated save, serve room `ROUTE` on port `9492`, and run `tests/fartrail_route_multiplayer_probe.gd` with `--connect=ws://127.0.0.1:9492 --room=ROUTE` and identities `--player-token=route-a` / `--player-token=route-b` simultaneously.

Outpost coverage: `Godot --headless --path . --script res://tests/test_outpost.gd`. For cooperative jobs, use an isolated copy of `tests/fixtures/outpost_ready_world.json`, serve room `POST` on port `9463`, and launch `tests/outpost_multiplayer_probe.gd` simultaneously with `--connect=ws://127.0.0.1:9463 --room=POST` and identities `--player-token=outpost-a` / `--player-token=outpost-b`.

The **Western Trails** now span 36 contiguous 32-metre sections west and northwest of home. The original nine woodland layouts stay fixed. Seeded outer pinewoods offer three daily wood sources, bloom meadows one wood/two herbs, and glimmer groves two wood/one herb. Each source yields one shared unit per day; each trail cache supplies one personal provision once with **E**. Terrain streams independently around each player (at most nine sections), while discoveries, caches, depletion and homestead builds persist. The journal lists charted sections and the local HUD gives cache/home bearings. Outer regions use distinct graybox vegetation and palettes, not final art, elevation or continent-scale generation.

Expansion coverage: `Godot --headless --path . --script res://tests/test_wilderness_expansion.gd`. Use an isolated copy of `tests/fixtures/wilderness_expansion_ready_world.json`, serve room `OUTER` on port `9491`, and run `tests/wilderness_expansion_multiplayer_probe.gd` simultaneously with `--connect=ws://127.0.0.1:9491 --room=OUTER` and identities `--player-token=outer-a` / `--player-token=outer-b`. This checks independently streamed northern regions with shared charting and personal rewards.

Focused coverage: `Godot --headless --path . --script res://tests/test_wilderness.gd`. Copy `tests/fixtures/wilderness_ready_world.json` to an isolated save and serve room `WILD` on port `9461`. Launch `tests/wilderness_multiplayer_probe.gd` simultaneously with `--connect=ws://127.0.0.1:9461 --room=WILD` and distinct `--player-token=wild-a` / `--player-token=wild-b` identities to verify independent streams and claims with shared map discovery.

The game now opens with three play choices:

- **Play Offline** runs the authoritative world simulation on the player's device without opening a network listener. It uses `user://offline_world.json`.
- **Host LAN Game** lets the host play while their device owns the authoritative room. Up to seven more players can join `ws://<HOST-LAN-IP>:9080` with the displayed room code. It uses `user://hosted_world.json` and is available in native builds.
- **Join Room** connects to either a LAN host or a dedicated online room. Browser builds can play offline or join, but cannot host a WebSocket server; browser-local offline saves are best-effort because browser storage may be cleared.

The modes share the same world rules. Offline and hosted saves are deliberately separate so solo play never changes a shared hosted world. Command-line shortcuts are also available:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . -- --offline
/Applications/Godot.app/Contents/MacOS/Godot --path . -- --host --room=FAMILY
```

World saves are written through a temporary file before replacing the primary JSON. The previous valid checkpoint is retained beside it with a `.bak` suffix, and the game automatically recovers that backup if the primary file is missing or unreadable.

The easiest option is to double-click `run-server.command` in Finder. From Terminal, run:

```sh
./run-server.command
```

It starts room `HEARTH` on port `9080` using the normal persistent world. Press **Control-C** to stop it.

For a separate clean playtest world:

```sh
./run-server.command --fresh --room=TEST42 --port=9090
```

To start the authoritative server without the launcher:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9080
```

The default room code is `HEARTH`, and rooms accept at most eight active players. To run an isolated fresh playtest without touching the normal save:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9090 --room=TEST42 --save-file=/tmp/project-hearth-playtest.json
```

Start one or more clients from the editor or another terminal:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path .
```

For an automatic local connection:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . -- --connect=ws://127.0.0.1:9080
```

Add `--room=TEST42` when connecting to a server that uses a non-default room code.

Press **Connect**, move with WASD or the arrow keys, and press **E** (or controller A) to talk, gather, repair, or revive. Press **Space** (or controller X) near a creature for a basic attack; each successful hit has a short per-player recovery before another can deal damage. Press **R** (or controller right shoulder) for a two-damage Power Strike with a longer recovery. Press **F** (or controller left shoulder) to brace briefly and block one incoming creature hit; brace then enters a short personal cooldown. An injured standing player can press **Q** (or controller B) to consume one carried trail provision and restore one health; provisions cannot self-revive. Gather two wood and one herb, then press **C** (or controller Y) to craft the repair kit. Restart the client or server to verify the quest, shared project bag, creature, health, and cottage repairs remain changed.

On desktop, the mouse is captured after connecting and ordinary mouse movement looks around—no button needs to be held. Press **Escape** to release the cursor and click the game to capture it again. Controller uses the **right stick**. On Android, touch anywhere on the left half to place the floating movement stick, drag anywhere on the right half to look, and use the center crosshair to aim. Tap a nearby creature for a basic attack; while aiming at it, the contextual action offers **Brace** during an incoming attack or **Power strike** otherwise. Other valid targets use the same contextual action area. Crafting remains in the quest card when available. The game starts in first person. Desktop players can press **V** or click the controller's right stick to switch to a close over-the-shoulder third-person camera. Use the mouse wheel to adjust its distance. Movement follows the camera direction.

After repairing the cottage, use **E** at the outdoor gear rack to freely switch your personal outing kit. **Vanguard** keeps the balanced combat timings. **Guardian** gives a longer brace window and shorter brace cooldown but adds recovery to both successful attack types. A standing Guardian who braces within two metres of both a companion and attacking creature will spend that brace to intercept one hit; the threatened player's own brace resolves first. Kits never change damage, health, range, or available actions, persist with the player, and can always be switched back at home.

The repaired cottage also opens **Willowmere Pond**. Use **E** at its blue marker to cast, wait for the explicit **BITE** cue, then use **E** again during the one-second window to catch one personal riverfish. Reeling early or missing the cue safely resets only your cast. Cook a riverfish at the cottage fire for one personal trail provision and Cooking mastery; a currently required hearth stew always takes interaction priority. Players may instead store fish one at a time in the nearby eight-fish shared creel. When a cook carries no fish, the fire draws one from that persistent shared stock. Fishing mastery displays the identity title **Angler I** but does not change timing or yield.

The repaired cottage also renews the authored forest wood and herb nodes at the start of each world day. Gathered forage enters the shared project bag. At the cottage **Trailwork Bench**, press **C** (or use the contextual touch action) to spend one shared wood and one shared herb on one personal trail provision. Missed days never stack materials, empty-world catch-up never gathers them, and crafting awards no passive progression or currency.

Three teal building sockets around the repaired homestead provide the first bounded claimed-plot construction. Use **E** (or **Build lantern** on touch) to spend one shared wood and place a permanent warm trail lantern. The placer earns one personal Building mastery point; the lantern is shared, grants no power or income, never decays, and remains available to everyone in offline, LAN-hosted, and dedicated worlds.

During normal play the compact quest card shows only the current objective and progress. Press **F3** to show or hide the technical debug panel. Cottage repairs use bright blue labeled markers in front of the building and display a nearby interaction prompt.

Completing all three repairs grants one reputation point, changes Mara's response, reveals the Old Stone Ruins rumor, and records the repaired home in the chronicle. Talk to Mara again to begin **Welcome Lights**. She moves to the neighborhood gathering place, and players can use the three amber markers to light shared lanterns. Finishing the event improves neighborhood morale, grants another reputation point, and adds a second chronicle entry. These changes survive server restart.

The repaired cottage also reveals a **Chronicle Board**. New shared entries appear as a concise personal return summary; standing beside the board shows the full shared history. Use **E** (or **Read updates** on touch) to acknowledge every current entry for your identity. That read position persists independently, so one player never clears a companion's updates and a new identity may review history that predates their arrival.

Mara remembers each player's own meaningful conversations and one optional check-in per world day. Reaching three personal rapport grants that identity one permanent **Woven Hearth Charm**. The relationship HUD names it and a small warm charm appears on the player's model for companions; it grants no power, access, currency, or extra copies.

The neighborhood HUD also shows a persistent day and time. The clock advances only while someone is playing; waking an empty world advances its calendar by at most six game hours. After Welcome Lights, Mara visibly follows a morning cottage, afternoon market or neighborhood, evening gathering-place, and nighttime cottage routine. Required quest appearances always take priority over her schedule.

After Welcome Lights, follow the road north beyond the original forest boundary. Crossing into the seed-derived Northwood and reaching the Old Stone Ruins reveals both places on the shared map. Defeat the ruin guardian with **Space** or the Attack button, then use **E** at the blue marker to restore the ancient waystone. The restored route persists and lets any player use the glowing stones at home or at the ruins for fast travel. It also reveals one rotating Northwood trail-survey marker per world day; every player may record that shared marker once for personal Exploration mastery without consuming anyone else's opportunity. A downed player can still be revived by a nearby friend, or can press **E** to return safely to the cottage with permanent progress intact.

Restoring that route now brings **Nima**, a traveling mapmaker, to the home waystone and begins **Nima's Bearings**. Talk to her, recover the teal-marked field case she lost in Northwood, and return it. Different players may perform all three steps. The finder earns one Exploration mastery point, the speakers build their own Nima rapport, and completion permanently adds Nima and her map table to the neighborhood while raising morale and reputation and entering the shared chronicle. The story has no timer and never advances while the room is empty.

Nima's completed map table then reveals **Moonwell Glade** on the western edge of Northwood. Study the new annotation, reach the glade, and attune its three pale teal moonstones in any order. Different players may reveal, discover, and restore the landmark across sessions; discovery and first attunements grant only their performer normal Exploration mastery. Completion permanently wakes the luminous spring, raises shared morale and reputation once, and records the sanctuary in the chronicle. A standing injured player may rest at the restored Moonwell without supplies or time advancement, while downed players still require the established recovery flow.

When the produce stall and Moonwell are both complete, the glade opens the **Moonwell Supper**. Prepare three courses at its hearth; each consumes one moonroot from the shared project bag and one riverfish. A cook's personal fish is used first, while a cook carrying none may draw from the persistent cottage creel. Every course grants its cook normal Cooking mastery, and friends may split farming, fishing, storage, and cooking across sessions. Completion permanently dresses the gathering table, raises shared morale and reputation once, and records the meal without creating passive output or repeatable milestone rewards.

Ripe garden plots remain harvestable after a market request is filled, so leftover crops can support the supper or a later order. Harvesting still consumes each plot once, credits its farmer, and persists until the next world day's regrowth.

After cottage repair, **Furnish south yard (B)** opens a shared five-by-three furnishing plot. Move toward a nearby cell and hold the right mouse button to look while furnishing; the cursor stays free for the panel buttons. Choose a bench or flower box with **T**, rotate with **R**, and place with **E** for two shared wood. **Delete** removes the selected furnishing and refunds its wood; the on-screen buttons provide the same actions. Any companion can rearrange these decorative pieces. Layouts persist in version-25 saves and grant no repeatable progression rewards. The cottage and story objects cannot be removed.

Completing Briarwatch unlocks the **Watch lantern** furnishing recipe for everyone in the world; completing the Moonwell Supper unlocks the **Gathering table**. Use **T** in furnishing mode to browse the catalogue. Locked recipes name their prerequisite. Both keepsakes use the normal two-wood cost/refund and persistent grid placement, with no statistics or mastery rewards.

The same catalogue now includes **Foundation, Wall, Doorway, and Roof**. Each yard cell supports a foundation, four independently rotated wall/doorway sides, a roof, and its existing furnishing. Every piece costs/refunds two wood. Walls require a foundation; roofs require at least two sides. Remove the roof before its last two supports, and all supports before the foundation. Quarter-turn rotation chooses the side to build or remove. Walls and doorway posts block authoritative movement, while the doorway center stays passable. Placement cannot intersect active players. Version-33 saves preserve structures; older worlds retain their furnishings and start with no structures. This is single-storey shared-yard construction, not wilderness claims, multi-storey building, or final architectural art.

Structural checks: `Godot --headless --path . --script res://tests/test_structures.gd`. Copy `tests/fixtures/structures_ready_world.json` to an isolated save, serve room `STRUCT` on port `9467`, and launch `tests/structures_multiplayer_probe.gd` simultaneously with `--connect=ws://127.0.0.1:9467 --room=STRUCT` and identities `--player-token=structure-a` / `--player-token=structure-b`. These check contested placement, cooperative construction/removal, conserved wood, wall collision, and doorway passage.

Focused building checks: run `Godot --headless --path . --script res://tests/test_furnishing.gd`. For shared placement, copy `tests/fixtures/furnishing_ready_world.json` to an isolated save, start a server with room `BUILD`, then run `tests/furnishing_multiplayer_probe.gd` simultaneously with `--connect=ws://127.0.0.1:9446 --room=BUILD` and the identities `--player-token=builder-a` and `--player-token=builder-b`. Both probes verify contested placement, companion removal, rotation, and conserved wood. To check the story keepsakes instead, use `tests/fixtures/keepsake_furnishing_ready_world.json` and add `--keepsakes` to both clients.

Network clients reserve a bounded 1 MiB incoming WebSocket buffer to absorb full-world snapshots during brief browser main-thread stalls. After joining a live room in Chromium, run `playwright-cli -s=<session> run-code --filename=tests/browser_stall_probe.js` to check three 1.2-second stalls for packet-buffer overflow. The client must already be connected; this focused regression does not prove indefinite background-tab suspension or production-scale snapshot capacity.

New offline, LAN-hosted, and dedicated worlds now receive a saved world seed. Northwood scenery, daily forecasts, and survey rotation use that seed, and joining clients receive it from the authority. Existing saves retain their recorded seed or the original `73021` fallback. Use `--world-seed=112358` when creating a world for a reproducible layout; the option never replaces the seed in an existing save or backup. F3 shows the active seed for diagnostics. Authored story sites stay fixed; larger regions and streaming remain future work.

Seed checks: `Godot --headless --path . --script res://tests/test_world_seed.gd`. For two-client synchronization, copy `tests/fixtures/world_seed_ready_world.json` to an isolated save, run a server on port `9448` with room `SEED`, then run `tests/world_seed_multiplayer_probe.gd` twice with `--connect=ws://127.0.0.1:9448 --room=SEED` and distinct `--player-token=seed-a` / `--player-token=seed-b` identities. Each client checks both the received seed and generated scenery transforms.

Rooms now accept up to eight distinct players. After the produce stall opens, an empty room records when it goes to sleep. Returning players receive at most three safe catch-up trail provisions at the stall; press **E** there to take one. Use a provision while injured for one health, or press **E** near an injured standing friend to spend one of your provisions on their recovery. An injured standing player can also press **E** at the repaired cottage bedroll to rest and recover fully without advancing time or affecting companions. Returning home while downed leaves carried provisions in a persistent trail pack where the player fell, and either the owner or a friend can recover it for the owner. On Android, **Aid friend**, **Rest**, and **Use provision** appear as contextual actions when eligible.

A standing player carrying a trail provision can press **E** near a healthy standing friend to hand over one provision. Revive and injury aid resolve first, followed by valid world interactions, so a handoff never replaces urgent help or a station action. The nearest eligible friend is chosen deterministically, transferred inventory persists for both identities, and the touch action reads **Give provision**.

Each accepted market unit pays its contributing player one persistent coin. Once the produce stall is open, use **E** at the nearby supply basket to spend two coins on one personal trail provision; free pantry stock remains separate. The basket holds three shared units per world day. Purchases consume that stock authoritatively, and the next day resets it to three rather than stacking missed stock. Coin is personal, never drops on defeat, and does not accrue while the room is empty.

The open stall also reveals the neighborhood's first optional shared project beside the cottage. Use **E** at the Hearthbloom planter frame to contribute one personal coin at a time. Four total contributions permanently bloom the planter, raise neighborhood morale and reputation once, and record the improvement in the chronicle. One player may finish it over time or friends may pool their earnings; partial progress never decays.

Opening the produce stall also begins the **Hearthlight Festival**. Use **E** at the gold festival arch to opt into the Hearthlight Circuit; use it again when the entrants are ready to start. Follow the three numbered gold checkpoints in order. The server records the first finisher, every finisher earns one persistent cosmetic ribbon, and gear, mastery, and provisions give no advantage. The first completed circuit raises neighborhood morale and reputation, leaves festival decorations in the gathering place, and adds the celebration to the chronicle. Use the arch again after the results to replay the activity.

## Run the state test

Press **J** or click **Activity journal** to browse revealed stories and activities. Pin one to your own objective card, or restore automatic guidance. Each identity's choice persists separately in its world; pins never reserve quests or alter companions' objectives. The journal reserves local controls while open, but does not pause the shared world.

Journal coverage: `Godot --headless --path . --script res://tests/test_activity_journal.gd`. The play-mode test also checks offline pin save/load. For a connected independence check, copy `tests/fixtures/sunwheat_ready_world.json` to a temporary save, serve room `JOURNAL` on port `9455`, and run `tests/activity_journal_multiplayer_probe.gd` twice with `--connect=ws://127.0.0.1:9455 --room=JOURNAL` and distinct identities `--player-token=journal-a` / `--player-token=journal-b`.

After restoring the ruins waystone, follow the road farther north to **Briarwatch**. Begin the outing at its entrance, break three spirit bindings with **E**, and rekindle the beacon. Leave the spirit's marked ground before its pulse or time **F** to brace; ordinary strikes cannot reach it. Broken bindings persist through retreat and disconnect. The restored beacon ends the danger and returns travelers home, with one permanent neighborhood chronicle entry.

Briarwatch coverage: `Godot --headless --path . --script res://tests/test_briarwatch.gd`. For a cooperative outing, copy `tests/fixtures/briarwatch_ready_world.json` to a temporary save, serve room `BRIAR` on port `9457`, and run `tests/briarwatch_multiplayer_probe.gd` twice with `--connect=ws://127.0.0.1:9457 --room=BRIAR` and identities `--player-token=briar-a` / `--player-token=briar-b`.

After repairing Oren's mill, Reedbank's three beds support a repeatable sunwheat loop: sow, wait two active minutes, harvest two grain, mill two grain into one flour, then bake one flour plus one herb into two trail provisions. Plantings and shared ingredients persist; empty-world catch-up can ripen but never harvest or replant crops.

Run `Godot --headless --path . --script res://tests/test_sunwheat.gd` for focused coverage. The fixture `tests/fixtures/sunwheat_ready_world.json` starts with one mature bed. Copy it to a temporary save, serve room `WHEAT` on port `9453`, and run `tests/sunwheat_multiplayer_probe.gd` simultaneously with `--connect=ws://127.0.0.1:9453 --room=WHEAT` and identities `--player-token=wheat-a` / `--player-token=wheat-b` to check the farmer-to-baker handoff.

Reedbank Hollow adds an eastern Northwood trail after Nima settles. Meet Oren, recover his sail from the northern reeds, fit it at the mill with two shared wood, and return to him to open a permanent rest shelter. Progress is shared across offline, LAN, and dedicated-room play; version-26 saves preserve each step.

Focused content coverage: `Godot --headless --path . --script res://tests/test_reedbank.gd`. For the companion handoff check, copy `tests/fixtures/reedbank_ready_world.json` to a temporary save, start a server with `--port=9451 --room=REEDS --save-file=<temporary-save>`, then run `tests/reedbank_multiplayer_probe.gd` twice with `--connect=ws://127.0.0.1:9451 --room=REEDS` and distinct `--player-token=reedbank-a` / `--player-token=reedbank-b` identities. The browser pass starts from the same fixture and plays the full chain using WASD/E.

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/test_world_state.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/test_living_world_readability.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/test_exploration_readability.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/test_livelihood_readability.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/test_shared_world_readability.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/test_festival_readability.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/test_movement_smoothing.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/test_camera.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/test_touch_controls.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/test_play_modes.gd
```

## Build and run the browser client

Export the single-threaded Web build:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-debug Web exports/web/index.html
```

Serve the exported files locally:

```sh
python3 -m http.server 8060 --directory exports/web
```

Open `http://127.0.0.1:8060`, enter `ws://127.0.0.1:9080`, and connect to the same headless server used by the native client.

## Build the Android debug client

```sh
mkdir -p exports/android
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-debug "Android Debug" exports/android/project-hearth-debug.apk
```

The prototype package ID is `com.example.projecthearth`; choose the permanent production ID before publishing to an app store.

For the Android emulator, forward its localhost port before pressing Connect:

```sh
adb reverse tcp:9080 tcp:9080
```

On a physical Android device, replace `127.0.0.1` with the Mac's local-network address, such as `ws://192.168.1.20:9080`. The phone and Mac must be on the same network, and the server must be allowed through the Mac firewall.

## Test across your private network

Start the server on the Mac:

```sh
./run-server.command --fresh --room=FAMILY
```

The launcher prints the private-network address, such as `ws://192.168.1.20:9080`. Enter that address and room code on each Windows, browser, or Android client. Keep every device on the same home network, allow Godot through the Mac firewall, and do not configure router port forwarding.

To make the browser build available to other devices too:

```sh
python3 -m http.server 8060 --bind 0.0.0.0 --directory exports/web
```

Open `http://<MAC-LAN-IP>:8060` on the other device, then connect the game to `ws://<MAC-LAN-IP>:9080`. Guest Wi-Fi may block devices from seeing each other.

## Build the Windows debug client from macOS

```sh
mkdir -p exports/windows
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-debug "Windows Debug" exports/windows/project-hearth.exe
```

Copy the entire `exports/windows` folder to the Windows computer when Vertical Slice 1 is ready for cross-platform testing. If the authoritative server stays on the Mac, connect from Windows using the Mac's local-network address, such as `ws://192.168.1.20:9080`.

## Pull, build, and test on Windows

1. Pull the repository and open it with the same stable Godot version used by the project.
2. Install the matching export templates from **Editor → Manage Export Templates**.
3. In PowerShell, build with:

```powershell
.\build-windows.ps1 -GodotPath "C:\path\to\Godot_v4.7.2-stable_win64_console.exe"
```

4. Run `exports\windows\project-hearth.exe`. Keep its neighboring `.pck` file with it.
5. Connect to the private-network address printed by the Mac server and use the same room code.

If Windows cannot reach the Mac, check the port from PowerShell with `Test-NetConnection <MAC-LAN-IP> -Port 9080`.

## Run the two-client networking probe

Start an isolated server, then launch these two commands at the same time with distinct player tokens:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9192 --room=PROBE --save-file=/tmp/project-hearth-multiplayer-probe.json
```

In two more Terminal windows, run:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/multiplayer_probe.gd -- --connect=ws://127.0.0.1:9192 --room=PROBE --player-token=probe-leader --probe-role=leader
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/multiplayer_probe.gd -- --connect=ws://127.0.0.1:9192 --room=PROBE --player-token=probe-helper --probe-role=helper
```

The probe verifies that both clients see the same quest stage, one resource cannot be duplicated, and one player can revive the other.

For the Slice 6 festival regression, copy `tests/fixtures/slice6_ready_world.json` to a temporary path, start an isolated room with that save, then run two festival probes simultaneously:

```sh
cp tests/fixtures/slice6_ready_world.json /tmp/project-hearth-slice6-network.json
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9298 --room=FESTIVAL --save-file=/tmp/project-hearth-slice6-network.json
```

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/festival_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9298 --room=FESTIVAL --player-token=festival-leader --probe-role=leader
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/festival_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9298 --room=FESTIVAL --player-token=festival-helper --probe-role=helper
```

The probes verify explicit enrollment, ordered checkpoints, the server-owned first finisher, shared results, and one persistent ribbon per finisher.

For the Hearthbloom contribution regression, copy `tests/fixtures/hearthbloom_ready_world.json` to a temporary path, start an isolated server on port `9397` with room `PROJECT`, and run these clients simultaneously:

```sh
cp tests/fixtures/hearthbloom_ready_world.json /tmp/project-hearth-hearthbloom-network.json
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9397 --room=PROJECT --save-file=/tmp/project-hearth-hearthbloom-network.json
```

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/hearthbloom_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9397 --room=PROJECT --player-token=project-a
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/hearthbloom_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9397 --room=PROJECT --player-token=project-b
```

The two probes verify that separate personal balances contribute exactly four conserved coins, produce one shared completion, and expose the same permanent rewards to both clients.

For the personal outing-kit regression, copy `tests/fixtures/outing_kits_ready_world.json`, start an isolated server on port `9399` with room `KITS`, and run these clients simultaneously:

```sh
cp tests/fixtures/outing_kits_ready_world.json /tmp/project-hearth-outing-kits-network.json
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9399 --room=KITS --save-file=/tmp/project-hearth-outing-kits-network.json
```

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/outing_kit_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9399 --room=KITS --player-token=kit-a
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/outing_kit_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9399 --room=KITS --player-token=kit-b
```

The probes verify that each kit choice synchronizes to both clients, remains independent per identity, and can be freely reversed without altering a companion's loadout.

For the cooperative Guardian-intercept regression, copy `tests/fixtures/guardian_intercept_ready_world.json`, start an isolated server on port `9401` with room `INTERCEPT`, and run both combat probes simultaneously:

```sh
cp tests/fixtures/guardian_intercept_ready_world.json /tmp/project-hearth-guardian-intercept-network.json
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9401 --room=INTERCEPT --save-file=/tmp/project-hearth-guardian-intercept-network.json
```

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/guardian_intercept_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9401 --room=INTERCEPT --player-token=intercept-target
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/guardian_intercept_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9401 --room=INTERCEPT --player-token=intercept-guardian
```

The probes verify that one synchronized Guardian brace protects the nearby Vanguard, is consumed exactly once, and leaves the targeted player at full health.

For the independent fishing-timing regression, copy `tests/fixtures/fishing_ready_world.json`, start an isolated server on port `9403` with room `FISHING`, and run both fishing probes simultaneously:

```sh
cp tests/fixtures/fishing_ready_world.json /tmp/project-hearth-fishing-network.json
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9403 --room=FISHING --save-file=/tmp/project-hearth-fishing-network.json
```

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/fishing_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9403 --room=FISHING --player-token=fishing-a
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/fishing_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9403 --room=FISHING --player-token=fishing-b
```

The probes verify simultaneous personal cast phases, an early reel that cannot disturb a companion, one server-awarded catch, and independent Fishing mastery.

For the direct provision-handoff regression, copy `tests/fixtures/provision_handoff_ready_world.json`, start an isolated server on port `9405` with room `HANDOFF`, and run both probes simultaneously:

```sh
cp tests/fixtures/provision_handoff_ready_world.json /tmp/project-hearth-handoff-network.json
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9405 --room=HANDOFF --save-file=/tmp/project-hearth-handoff-network.json
```

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/provision_handoff_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9405 --room=HANDOFF --player-token=handoff-giver
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/provision_handoff_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9405 --room=HANDOFF --player-token=handoff-recipient
```

The probes verify that both peers observe one authoritative transfer and that their combined personal provision count is conserved.

For the bounded daily-supply race, copy `tests/fixtures/daily_supply_ready_world.json`, start an isolated server on port `9407` with room `SUPPLY`, and run both buyer probes simultaneously:

```sh
cp tests/fixtures/daily_supply_ready_world.json /tmp/project-hearth-daily-supply.json
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9407 --room=SUPPLY --save-file=/tmp/project-hearth-daily-supply.json
```

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/daily_supply_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9407 --room=SUPPLY --player-token=supply-a
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/daily_supply_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9407 --room=SUPPLY --player-token=supply-b
```

The probes verify that simultaneous buyers can purchase the last shared unit only once, conserving both stock and coin.

For the shared-creel conservation race, copy `tests/fixtures/shared_creel_ready_world.json`, start an isolated server on port `9409` with room `CREEL`, and run both cook probes simultaneously:

```sh
cp tests/fixtures/shared_creel_ready_world.json /tmp/project-hearth-shared-creel.json
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9409 --room=CREEL --save-file=/tmp/project-hearth-shared-creel.json
```

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/shared_creel_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9409 --room=CREEL --player-token=creel-a
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/shared_creel_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9409 --room=CREEL --player-token=creel-b
```

The probes verify that simultaneous cooks consume the final shared fish only once, granting exactly one provision and one Cooking mastery credit.

For Mara's personal keepsake milestone, copy `tests/fixtures/mara_keepsake_ready_world.json`, start an isolated server on port `9411` with room `KEEPSAKE`, and run both visibility probes simultaneously:

```sh
cp tests/fixtures/mara_keepsake_ready_world.json /tmp/project-hearth-mara-keepsake.json
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9411 --room=KEEPSAKE --save-file=/tmp/project-hearth-mara-keepsake.json
```

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/mara_keepsake_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9411 --room=KEEPSAKE --player-token=keepsake-a
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/mara_keepsake_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9411 --room=KEEPSAKE --player-token=keepsake-b
```

The probes verify that the third rapport point awards one persistent charm and that both peers immediately render the new keepsake.

For the daily personal-survey regression, copy `tests/fixtures/daily_survey_ready_world.json`, start an isolated server on port `9413` with room `SURVEY`, and run both surveyors simultaneously:

```sh
cp tests/fixtures/daily_survey_ready_world.json /tmp/project-hearth-daily-survey.json
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9413 --room=SURVEY --save-file=/tmp/project-hearth-daily-survey.json
```

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/daily_survey_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9413 --room=SURVEY --player-token=survey-a
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/daily_survey_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9413 --room=SURVEY --player-token=survey-b
```

The probes verify that both players can record the same daily marker once and receive their own conserved Exploration credit.

For the shared trailcraft conservation regression, copy `tests/fixtures/trailcraft_ready_world.json`, start an isolated server on port `9415` with room `TRAILCRAFT`, and run both crafters simultaneously:

```sh
cp tests/fixtures/trailcraft_ready_world.json /tmp/project-hearth-trailcraft.json
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9415 --room=TRAILCRAFT --save-file=/tmp/project-hearth-trailcraft.json
```

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/trailcraft_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9415 --room=TRAILCRAFT --player-token=trailcraft-a
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/trailcraft_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9415 --room=TRAILCRAFT --player-token=trailcraft-b
```

The probes verify that simultaneous crafters each receive one personal provision while consuming exactly the four shared ingredients once.

For the shared homestead-building race, copy `tests/fixtures/homestead_build_ready_world.json`, start an isolated server on port `9417` with room `BUILD`, and run both builders simultaneously:

```sh
cp tests/fixtures/homestead_build_ready_world.json /tmp/project-hearth-homestead-build.json
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9417 --room=BUILD --save-file=/tmp/project-hearth-homestead-build.json
```

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/homestead_build_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9417 --room=BUILD --player-token=builder-a
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/homestead_build_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9417 --room=BUILD --player-token=builder-b
```

The probes verify that simultaneous placements competing for the final shared wood produce exactly one persistent lantern and one personal Building credit.

For independent returning-player chronicle state, copy `tests/fixtures/chronicle_board_ready_world.json`, start an isolated server on port `9419` with room `CHRONICLE`, and run both readers simultaneously:

```sh
cp tests/fixtures/chronicle_board_ready_world.json /tmp/project-hearth-chronicle-board.json
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9419 --room=CHRONICLE --save-file=/tmp/project-hearth-chronicle-board.json
```

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/chronicle_board_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9419 --room=CHRONICLE --player-token=chronicle-a
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/chronicle_board_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9419 --room=CHRONICLE --player-token=chronicle-b
```

The probes verify that both players see the same shared history while their acknowledgements persist and replicate independently.

For Nima's cooperative resident story, copy `tests/fixtures/nima_story_ready_world.json`, start an isolated server on port `9425` with room `NIMA`, and run both participants simultaneously:

```sh
cp tests/fixtures/nima_story_ready_world.json /tmp/project-hearth-nima-story.json
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9425 --room=NIMA --save-file=/tmp/project-hearth-nima-story.json
```

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/nima_story_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9425 --room=NIMA --player-token=nima-a
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/nima_story_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9425 --room=NIMA --player-token=nima-b
```

The probes verify that one player can handle Nima's conversations while another recovers the field case, with correct individual credit and one shared persistent consequence.

For Moonwell Glade's cooperative landmark story, copy `tests/fixtures/moonwell_story_ready_world.json`, start an isolated server on port `9441` with room `MOONWELL`, and run both participants simultaneously:

```sh
cp tests/fixtures/moonwell_story_ready_world.json /tmp/project-hearth-moonwell-story.json
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9441 --room=MOONWELL --save-file=/tmp/project-hearth-moonwell-story.json
```

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/moonwell_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9441 --room=MOONWELL --player-token=moonwell-a
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/moonwell_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9441 --room=MOONWELL --player-token=moonwell-b
```

The probes verify that one player can reveal the destination while another discovers and restores it, with conserved personal credit, one shared consequence, and networked sanctuary recovery.

For the cross-livelihood Moonwell Supper, copy `tests/fixtures/moonwell_supper_ready_world.json`, start an isolated server on port `9443` with room `SUPPER`, and run both cooks simultaneously:

```sh
cp tests/fixtures/moonwell_supper_ready_world.json /tmp/project-hearth-moonwell-supper.json
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9443 --room=SUPPER --save-file=/tmp/project-hearth-moonwell-supper.json
```

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/moonwell_supper_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9443 --room=SUPPER --player-token=supper-a
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/moonwell_supper_multiplayer_probe.gd -- --connect=ws://127.0.0.1:9443 --room=SUPPER --player-token=supper-b
```

The probes verify personal-fish priority, creel fallback, conserved shared moonroot, individual cook credit, and one shared persistent supper consequence.

## Slice 0 platform status

- macOS development client: connection, movement, collection, and persistence verified
- Desktop Web client: export, rendering, connection, movement, and collection verified
- Android client: debug APK export, rendering, connection, touch movement, and collection verified on a Pixel 7a emulator
- Windows client: export verified on macOS; runtime test deferred until Vertical Slice 1

## Slice 1 verification status

- World rules and version-3 persistence: automated state test passes
- macOS development build: parsing and rendered-scene smoke test pass
- Desktop Web: rebuilt, rendered, connected, and accepted movement with no console errors
- Android: rebuilt, installed, rendered, connected, and accepted touch movement on the Pixel 7a emulator
- Windows: exported build runs and connects to the Mac server over the private network; Mac and Windows players are mutually visible
- Two-client networking: shared quest stage, resource duplication prevention, and revival verified simultaneously on macOS
- Deferred release validation: repeat the cumulative loop with fresh players and complete a full runtime pass on every target platform once the game has taken more shape

## Slice 2 implementation status

- Welcome Lights is a server-authoritative response to the completed cottage repair.
- Version-11 persistence stores the authoritative neighborhood clock and renewable market-request state. The clock performs bounded safe calendar catch-up and drives Mara's post-event daily routine without overriding required quest appearances.
- Personal Combat mastery records successful damaging attacks and exposes a Warden identity title without changing combat power. Existing Version-11 saves add the new track at zero when a player returns.
- Personal Exploration mastery credits the player who first reveals Northwood or the Old Stone Ruins and exposes a Pathfinder identity title; the map discovery and route access remain shared. Existing Version-11 saves add the track at zero when a player returns.
- Personal Building mastery credits successful cottage-part placements and exposes a Builder identity title without changing shared costs, placement rules, or the repaired home's shared rewards. Existing Version-11 saves add the track at zero when a player returns.
- Forest-creature and ruin-guardian attacks now expose a short server-authoritative wind-up and locked target. The target can brace or leave strike range before resolution; wind-up state is shared live across offline, LAN-hosted, and dedicated play but is never persisted.
- Every newcomer can use a server-authoritative Power Strike for two damage at the cost of a longer personal recovery. It shares basic-attack range and grants one Combat mastery credit per successful action, with no cost for an invalid attempt.
- The repaired-home gear rack supports the first persistent personal loadout choice. Vanguard preserves the established timings; Guardian improves brace timing while slowing successful attack recovery, and every player can switch freely without mastery or currency.
- A nearby standing Guardian can now spend an active brace to intercept one telegraphed creature hit for a companion. The target's own brace has priority, and deterministic distance and identity ordering keeps the same result in offline, LAN-hosted, and dedicated play.
- Authored enemies remain inside server-authoritative home areas. When every standing player disengages beyond the boundary, pending pressure ends, the enemy visibly returns to spawn, and its health resets only on arrival.
- A defeated forest creature remains gone for the rest of the current world day and returns at full health on the next day, including after bounded empty-room catch-up. The ruin guardian remains a persistent one-time story defeat.
- Mara persistently remembers each player's meaningful story conversations. After Welcome Lights, each identity may check in once per world day for personal rapport and warmer recognition. Three rapport awards one visible Woven Hearth Charm; Version-18 persistence retains the cosmetic and migrates already-qualified identities without gating shared progress or power.
- Market deliveries now pay one persistent personal coin per accepted unit. The supply basket sells trail provisions for two coins through the same authoritative offline, LAN-hosted, and dedicated-world rules.
- The four-coin Hearthbloom planter is the first optional contribution-funded homestead project. Its partial and completed states persist, and completion produces one visible shared change plus one-time morale, reputation, and chronicle recognition without player power.
- The region seed and world day select a shared clear, overcast, or gentle-rain forecast. The clock drives readable day/night colors and light. Weather never punishes absence or changes movement or combat; after the produce stall opens, it safely frames the current renewable food request.
- World persistence uses atomic replacement and one previous-valid backup across offline, LAN-hosted, and dedicated saves; invalid primary JSON recovers automatically.
- Mara's event-driven routine, the three-player-shared lantern states, neighborhood morale, and chronicle entries use version-4 persistence; version-3 Slice 1 saves migrate into Mara's invitation.
- The cottage Chronicle Board uses version-21 persistence for independent player read positions. Existing history remains unread after migration so returning and newly joining identities can catch up; acknowledging it grants no reward and never changes another player's view.
- Nima's Bearings uses version-22 persistence for the first condition-triggered additional resident story. Existing restored-route worlds migrate into her arrival, cooperative steps remain shared, conversation rapport and fieldwork credit remain personal, and completion leaves one persistent map table and scheduled resident.
- Moonwell Glade uses version-23 persistence for the first map-table follow-up landmark. Existing completed Nima stories migrate to its unread lead; reveal, discovery, and three attunements persist as shared state, while individual Exploration credit and the completed sanctuary recovery rule remain authoritative in every play mode.
- Moonwell Supper uses version-24 persistence for the first cross-livelihood community meal. Existing worlds with both the produce stall and restored Moonwell migrate into the opportunity; three conserved courses persist across sessions, cooks retain individual mastery, and completion leaves one shared dressed table and chronicle outcome.
- Authoritative 20 Hz player positions are interpolated on rendered frames so movement and the following camera remain smooth without moving authority to the client.
- Automated state, migration, presentation, and legacy regression checks pass.
- Two simultaneous macOS clients still pass the shared-state networking probe.
- Desktop Web, Android, and Windows debug exports rebuild successfully.
- Fresh-player and full desktop Web, Android, and Windows runtime validation are intentionally deferred during the cumulative implementation pass. New work receives automated coverage and a focused exported-Web functionality/visual check through Playwright CLI; Windows may be used as the second multiplayer client.

## Slice 3 implementation status

- A deterministic seed-derived Northwood extends the playable world beyond the original forest boundary and leads to the authored Old Stone Ruins landmark.
- Northwood and the ruins reveal for the entire room through a visible shared map.
- A server-authoritative ruin guardian creates the first-journey combat obstacle; existing cooperative revive remains available, and a downed solo player can return safely to the cottage.
- Defeating the guardian allows the group to restore a persistent waystone route between home and the ruins. The discovery and restoration enter the shared chronicle and survive version-5 save/load; version-4 saves migrate into the new journey.
- The restored route reveals one deterministic Northwood trail survey per day. Version-19 persistence remembers each identity's last recorded day, while the shared marker remains independently available to every companion and empty-world time grants no mastery.
- Automated state, migration, presentation, legacy-regression, and two-client networking checks pass.
- Exported desktop Web: the complete fresh-world journey passes in Chromium, including shared discovery, repeated solo guardian failure/return, eventual combat success, and waystone restoration.

## Slice 4 implementation status

- Restoring the ruin waystone reveals a shared neighborhood food need.
- Four persistent garden plots supply moonroot; the cottage cookfire turns pairs into hearth stew; the market crate accepts two deliveries.
- Farming, Cooking, and Trade mastery belongs to the player who performs each action, while materials and settlement progress remain shared.
- Tier-II mastery adds convenience rather than exclusive power: experienced farmers can tend one adjacent plot, cooks can batch prepared stew work, and traders can bulk-deliver matching goods. New players retain every base action, and mastery credit remains per unit.
- Completion opens a visible produce stall, improves morale and reputation, and adds a fourth chronicle entry.
- Beginning with the next in-game day, all four moonroot plots regrow. Clear days request three fresh moonroot, gentle-rain days request two hearth stews, and overcast days alternate by day parity. The HUD explains the choice. Completing any request awards normal personal mastery and adds one bounded pantry provision without repeating milestone reputation, morale, or chronicle rewards.
- Willowmere Pond adds independent server-authoritative cast, wait, bite, early-reel, and missed-bite states. Successful catches persist as personal riverfish and Fishing mastery; the cookfire converts one fish into one personal trail provision while preserving required-stew priority. Version-15 saves persist catches but deliberately exclude in-progress casts.
- The repaired cottage adds a bounded eight-fish shared creel. Version-17 persistence conserves its stock, older worlds migrate empty, and the cookfire uses shared fish only when the cook carries none.
- Version-6 persistence migrates version-5 worlds into the food need when their waystone route is already active.
- State, migration, presentation, legacy regression, the original two-client probe, and a networked end-to-end livelihood probe pass.
- Focused Mac inspection of the active need and completed stall passes after correcting garden-label overlap, chronicle height, and the home-waystone placement.
- Exported desktop Web: the uninterrupted cumulative Slice 3–4 journey passes through garden harvesting, cooking, deliveries, mastery, and the persistent produce stall; broader fresh-player and all-target runtime validation remains deferred.

## Slice 5 implementation status

- Authoritative rooms accept up to eight distinct active player identities; reconnecting resumes persistent state and a second active copy of the same identity is rejected.
- The HUD shows online capacity. Completed produce stalls gain at most three provisions after the room has been empty, using a short prototype interval for practical testing.
- Trail provisions belong to individual players. Returning to safety while downed leaves a persistent recovery pack that a nearby friend can restore to its owner.
- Nearby healthy friends can receive one direct trail-provision handoff. Revive, injury aid, and valid world interactions keep priority; deterministic active-player selection conserves inventory and cannot target an offline identity.
- The coin-funded supply basket now has three shared units per world day. Version-16 persistence retains current stock, older completed worlds migrate full, and a new day resets stock without accumulating missed inventory.
- Version-7 persistence migrates version-6 worlds without granting retroactive stock, provisions, or packs.
- Automated state, migration, presentation, legacy-regression, and eight-client capacity coverage pass.
- Focused desktop Web verification passes in Chromium with no console errors: room connection, WASD movement, camera toggle, pantry interaction, downed return, and recovery-pack presentation all work through the exported build.
- The uninterrupted fresh-world Slice 3–5 Chromium journey passes, including two solo guardian failures and returns, eventual route restoration, the full livelihood loop, empty-room sleep, reconnect catch-up, and pantry pickup. Playwright's persistent-profile harness emitted a non-blocking pointer-lock document message on reconnect; focused gameplay runs and the camera regression test remain clean.
- Verification priority is browser first through the exported Web build, then Windows desktop and native Android. Linux deployment packaging is deferred.
- Fresh-player usability and full desktop Web, Android, and Windows runtime validation remain deferred.

## Slice 6 implementation status

- The completed produce stall opens the Hearthlight Festival and its replayable three-checkpoint circuit at the neighborhood gathering place.
- One to eight players explicitly opt in; the authoritative server owns enrollment, ordered progress, first-finisher results, disconnect cleanup, and replay state.
- Standard movement is normalized for every entrant. Gear, mastery, provisions, and non-participants cannot affect the result, so the activity is opt-in competition without hostile open-world PvP.
- Every finisher earns one persistent cosmetic festival ribbon. The first completed run raises morale and reputation, adds persistent festival decorations, and records a fifth chronicle entry.
- Version-8 persistence migrates version-7 worlds, preserves completed festival history and ribbons, and safely reopens interrupted runs after restart.
- State, migration, presentation, legacy regression, and simultaneous two-client festival coverage pass.
- The exported desktop Web build completes the focused solo festival loop in Chromium: join, start, all three checkpoints, results, ribbon, decorations, and chronicle persistence are visible and functional.
- Fresh-player usability and full desktop Web, Android, and Windows runtime validation remain deferred.

Restart any older running server before connecting a current client. Godot rejects clients and servers with different RPC definitions, which is expected after multiplayer code changes.

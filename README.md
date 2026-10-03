# Project Hearth

Godot prototype for the multiplayer world game. Slice 0 proves authoritative networking and persistent shared state across Windows, desktop Web, and Android clients. The cumulative build now includes the minimum implementations of Slice 1, **A New Home**, Slice 2, **A Place That Remembers**, Slice 3, **Beyond the Road**, Slice 4, **Choose a Life**, Slice 5, **Our Shared World**, and Slice 6, **Gather and Celebrate**.

## Run locally on macOS

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

During normal play the compact quest card shows only the current objective and progress. Press **F3** to show or hide the technical debug panel. Cottage repairs use bright blue labeled markers in front of the building and display a nearby interaction prompt.

Completing all three repairs grants one reputation point, changes Mara's response, reveals the Old Stone Ruins rumor, and records the repaired home in the chronicle. Talk to Mara again to begin **Welcome Lights**. She moves to the neighborhood gathering place, and players can use the three amber markers to light shared lanterns. Finishing the event improves neighborhood morale, grants another reputation point, and adds a second chronicle entry. These changes survive server restart.

The neighborhood HUD also shows a persistent day and time. The clock advances only while someone is playing; waking an empty world advances its calendar by at most six game hours. After Welcome Lights, Mara visibly follows a morning cottage, afternoon market or neighborhood, evening gathering-place, and nighttime cottage routine. Required quest appearances always take priority over her schedule.

After Welcome Lights, follow the road north beyond the original forest boundary. Crossing into the seed-derived Northwood and reaching the Old Stone Ruins reveals both places on the shared map. Defeat the ruin guardian with **Space** or the Attack button, then use **E** at the blue marker to restore the ancient waystone. The restored route persists and lets any player use the glowing stones at home or at the ruins for fast travel. A downed player can still be revived by a nearby friend, or can press **E** to return safely to the cottage with permanent progress intact.

Rooms now accept up to eight distinct players. After the produce stall opens, an empty room records when it goes to sleep. Returning players receive at most three safe catch-up trail provisions at the stall; press **E** there to take one. Use a provision while injured for one health, or press **E** near an injured standing friend to spend one of your provisions on their recovery. An injured standing player can also press **E** at the repaired cottage bedroll to rest and recover fully without advancing time or affecting companions. Returning home while downed leaves carried provisions in a persistent trail pack where the player fell, and either the owner or a friend can recover it for the owner. On Android, **Aid friend**, **Rest**, and **Use provision** appear as contextual actions when eligible.

Each accepted market unit pays its contributing player one persistent coin. Once the produce stall is open, use **E** at the nearby supply basket to spend two coins on one personal trail provision; free pantry stock remains a separate first-priority pickup. Coin is personal, never drops on defeat, and does not accrue while the room is empty.

The open stall also reveals the neighborhood's first optional shared project beside the cottage. Use **E** at the Hearthbloom planter frame to contribute one personal coin at a time. Four total contributions permanently bloom the planter, raise neighborhood morale and reputation once, and record the improvement in the chronicle. One player may finish it over time or friends may pool their earnings; partial progress never decays.

Opening the produce stall also begins the **Hearthlight Festival**. Use **E** at the gold festival arch to opt into the Hearthlight Circuit; use it again when the entrants are ready to start. Follow the three numbered gold checkpoints in order. The server records the first finisher, every finisher earns one persistent cosmetic ribbon, and gear, mastery, and provisions give no advantage. The first completed circuit raises neighborhood morale and reputation, leaves festival decorations in the gathering place, and adds the celebration to the chronicle. Use the arch again after the results to replay the activity.

## Run the state test

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
- Authored enemies remain inside server-authoritative home areas. When every standing player disengages beyond the boundary, pending pressure ends, the enemy visibly returns to spawn, and its health resets only on arrival.
- A defeated forest creature remains gone for the rest of the current world day and returns at full health on the next day, including after bounded empty-room catch-up. The ruin guardian remains a persistent one-time story defeat.
- Mara persistently remembers each player's meaningful story conversations. After Welcome Lights, each identity may check in once per world day for personal rapport and warmer recognition; this does not gate shared progress, power, or rewards.
- Market deliveries now pay one persistent personal coin per accepted unit. The supply basket sells trail provisions for two coins through the same authoritative offline, LAN-hosted, and dedicated-world rules.
- The four-coin Hearthbloom planter is the first optional contribution-funded homestead project. Its partial and completed states persist, and completion produces one visible shared change plus one-time morale, reputation, and chronicle recognition without player power.
- The region seed and world day select a shared clear, overcast, or gentle-rain forecast. The clock drives readable day/night colors and light. Weather never punishes absence or changes movement or combat; after the produce stall opens, it safely frames the current renewable food request.
- World persistence uses atomic replacement and one previous-valid backup across offline, LAN-hosted, and dedicated saves; invalid primary JSON recovers automatically.
- Mara's event-driven routine, the three-player-shared lantern states, neighborhood morale, and chronicle entries use version-4 persistence; version-3 Slice 1 saves migrate into Mara's invitation.
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
- Automated state, migration, presentation, legacy-regression, and two-client networking checks pass.
- Exported desktop Web: the complete fresh-world journey passes in Chromium, including shared discovery, repeated solo guardian failure/return, eventual combat success, and waystone restoration.

## Slice 4 implementation status

- Restoring the ruin waystone reveals a shared neighborhood food need.
- Four persistent garden plots supply moonroot; the cottage cookfire turns pairs into hearth stew; the market crate accepts two deliveries.
- Farming, Cooking, and Trade mastery belongs to the player who performs each action, while materials and settlement progress remain shared.
- Tier-II mastery adds convenience rather than exclusive power: experienced farmers can tend one adjacent plot, cooks can batch prepared stew work, and traders can bulk-deliver matching goods. New players retain every base action, and mastery credit remains per unit.
- Completion opens a visible produce stall, improves morale and reputation, and adds a fourth chronicle entry.
- Beginning with the next in-game day, all four moonroot plots regrow. Clear days request three fresh moonroot, gentle-rain days request two hearth stews, and overcast days alternate by day parity. The HUD explains the choice. Completing any request awards normal personal mastery and adds one bounded pantry provision without repeating milestone reputation, morale, or chronicle rewards.
- Version-6 persistence migrates version-5 worlds into the food need when their waystone route is already active.
- State, migration, presentation, legacy regression, the original two-client probe, and a networked end-to-end livelihood probe pass.
- Focused Mac inspection of the active need and completed stall passes after correcting garden-label overlap, chronicle height, and the home-waystone placement.
- Exported desktop Web: the uninterrupted cumulative Slice 3–4 journey passes through garden harvesting, cooking, deliveries, mastery, and the persistent produce stall; broader fresh-player and all-target runtime validation remains deferred.

## Slice 5 implementation status

- Authoritative rooms accept up to eight distinct active player identities; reconnecting resumes persistent state and a second active copy of the same identity is rejected.
- The HUD shows online capacity. Completed produce stalls gain at most three provisions after the room has been empty, using a short prototype interval for practical testing.
- Trail provisions belong to individual players. Returning to safety while downed leaves a persistent recovery pack that a nearby friend can restore to its owner.
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

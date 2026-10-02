# Project Hearth

Godot prototype for the multiplayer world game. Slice 0 proves authoritative networking and persistent shared state across Windows, desktop Web, and Android clients. Slice 1, **A New Home**, is now in development.

## Run locally on macOS

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

The default room code is `HEARTH`, and rooms accept at most four registered players. To run an isolated fresh playtest without touching the normal save:

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

Press **Connect**, move with WASD or the arrow keys, and press **E** (or controller A) to talk, gather, repair, or revive. Press **Space** (or controller X) near the forest creature to attack. Gather two wood and one herb, then press **C** (or controller Y) to craft the repair kit. Restart the client or server to verify the quest, shared project bag, creature, health, and cottage repairs remain changed.

Completing all three repairs grants one reputation point, changes Mara's response, and reveals the Old Stone Ruins rumor at the forest boundary.

## Run the state test

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/test_world_state.gd
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

## Build the Windows debug client from macOS

```sh
mkdir -p exports/windows
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-debug "Windows Debug" exports/windows/project-hearth.exe
```

Copy the entire `exports/windows` folder to the Windows computer when Vertical Slice 1 is ready for cross-platform testing. If the authoritative server stays on the Mac, connect from Windows using the Mac's local-network address, such as `ws://192.168.1.20:9080`.

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
- Windows: rebuilt successfully on macOS; runtime test still requires the Windows computer
- Remaining gate: complete the full loop with 1–4 fresh players, then repeat the runtime check on Windows

Restart any older running server before connecting a current client. Godot rejects clients and servers with different RPC definitions, which is expected after multiplayer code changes.

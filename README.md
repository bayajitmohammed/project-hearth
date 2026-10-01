# Project Hearth

Godot prototype for the multiplayer world game. Slice 0 proves authoritative networking and persistent shared state across Windows, desktop Web, and Android clients. Slice 1, **A New Home**, is now in development.

## Run locally on macOS

Start the authoritative server:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --server --port=9080
```

Start one or more clients from the editor or another terminal:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path .
```

For an automatic local connection:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . -- --connect=ws://127.0.0.1:9080
```

Press **Connect**, move with WASD or the arrow keys, follow the arrival road, and recover the lost supplies near the forest. Restart the client to verify the same player position returns. Restart the server to verify the supplies stay collected.

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

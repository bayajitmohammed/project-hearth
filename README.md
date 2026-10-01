# Project Hearth

Godot prototype for the multiplayer world game. Slice 0 proves authoritative networking and persistent shared state across Windows, desktop Web, and Android clients.

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

Press **Connect**, move with WASD or the arrow keys, and touch the gold sphere. Restart the client to verify the same player position returns. Restart the server to verify the collected sphere stays gone.

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

## Slice 0 platform status

- macOS development client: connection, movement, collection, and persistence verified
- Desktop Web client: export, rendering, connection, movement, and collection verified
- Android client: pending
- Windows client: pending

#!/bin/zsh

set -euo pipefail

project_dir="${0:A:h}"
godot_bin="/Applications/Godot.app/Contents/MacOS/Godot"
server_port="9080"
room_code="HEARTH"
save_file=""

show_help() {
	print "Project Hearth server"
	print ""
	print "Usage: ./run-server.command [options]"
	print ""
	print "  --port=NUMBER       Server port (default: 9080)"
	print "  --room=CODE         Room code (default: HEARTH)"
	print "  --save-file=PATH    Use a specific world save"
	print "  --fresh             Use a new temporary world"
	print "  --help              Show this help"
}

for argument in "$@"; do
	case "$argument" in
		--port=*) server_port="${argument#--port=}" ;;
		--room=*) room_code="${argument#--room=}" ;;
		--save-file=*) save_file="${argument#--save-file=}" ;;
		--fresh)
			playtest_dir="$(mktemp -d /tmp/project-hearth-playtest.XXXXXX)"
			save_file="$playtest_dir/world.json"
			;;
		--help|-h)
			show_help
			exit 0
			;;
		*)
			print -u2 "Unknown option: $argument"
			show_help
			exit 2
			;;
	esac
done

if [[ ! -x "$godot_bin" ]]; then
	print -u2 "Godot was not found at: $godot_bin"
	exit 1
fi

room_code="${(U)room_code}"
server_args=(
	"--server"
	"--port=$server_port"
	"--room=$room_code"
)

if [[ -n "$save_file" ]]; then
	server_args+=("--save-file=$save_file")
fi

print "Starting Project Hearth server"
print "Room: $room_code"
print "Port: $server_port"
if [[ -n "$save_file" ]]; then
	print "Save: $save_file"
else
	print "Save: normal persistent world"
fi
print "Press Control-C to stop the server."
print ""

exec "$godot_bin" --headless --path "$project_dir" -- "${server_args[@]}"

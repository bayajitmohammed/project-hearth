extends Node3D

const World = preload("res://scripts/world_state.gd")
signal change_requested(cell: Vector2i, kind: String, quarter_turns: int, remove: bool, plot_id: String)
signal mode_changed(active: bool)

var active := false
var kind := "bench"
var quarter_turns := 0
var cell := Vector2i(-1, -1)
var can_place := false
var can_remove := false
var pieces: Dictionary = {}
var rendered_layout: Dictionary = {}
var rendered_structures: Dictionary = {}
var structure_nodes: Dictionary = {}
var plot_id := ""
var remote_roots: Dictionary = {}
var remote_layouts: Dictionary = {}
var remote_seed := -1
var station_markers: Dictionary = {}
var preview: Node3D
var grid: Node3D
var panel: VBoxContainer
var toggle: Button
var details: Label
var controls: VBoxContainer
var choose: Button
var place: Button
var remove_button: Button


func _ready() -> void:
	grid = Node3D.new()
	add_child(grid)
	for x: int in World.FURNISHING_COLUMNS:
		for z: int in World.FURNISHING_ROWS:
			_box(grid, Vector3(2.85, 0.025, 2.85), World.furnishing_position(Vector2i(x, z)), Color(0.45, 0.8, 0.7, 0.3))
	grid.visible = false
	var layer := CanvasLayer.new()
	add_child(layer)
	var card := PanelContainer.new()
	card.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	card.position = Vector2(-292, 20)
	card.custom_minimum_size.x = 272
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.09, 0.12, 0.95)
	style.set_content_margin_all(12)
	style.set_corner_radius_all(8)
	card.add_theme_stylebox_override("panel", style)
	layer.add_child(card)
	panel = VBoxContainer.new()
	card.add_child(panel)
	toggle = _button(panel, "Furnish south yard (B)", toggle_mode)
	controls = VBoxContainer.new()
	panel.add_child(controls)
	details = Label.new()
	details.custom_minimum_size.x = 248
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls.add_child(details)
	choose = _button(controls, "Bench · change (T)", cycle_piece)
	_button(controls, "Rotate 90° (R)", rotate_piece)
	place = _button(controls, "Place · 2 wood (E)", func() -> void: request_change(false))
	remove_button = _button(controls, "Remove · refund 2 wood (Delete)", func() -> void: request_change(true))
	_button(controls, "Done (B)", toggle_mode)
	controls.visible = false
	panel.get_parent().visible = false
	_rebuild_preview()


func _button(parent: Node, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 38
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func toggle_mode() -> void:
	active = not active
	controls.visible = active
	grid.visible = active
	preview.visible = active
	mode_changed.emit(active)


func cycle_piece() -> void:
	kind = World.BUILDING_KINDS[(World.BUILDING_KINDS.find(kind) + 1) % World.BUILDING_KINDS.size()]
	choose.text = "%s · change (T)" % _piece_name()
	_rebuild_preview()


func rotate_piece() -> void:
	quarter_turns = (quarter_turns + 1) % 4


func request_change(remove: bool) -> void:
	if active and ((remove and can_remove) or (not remove and can_place)):
		change_requested.emit(cell, kind, quarter_turns, remove, plot_id)


func update_view(snapshot: Dictionary, token: String, yaw: float, connected: bool) -> void:
	var layout: Dictionary = snapshot.get("furnishings", {})
	var structures: Dictionary = snapshot.get("structures", {})
	if structures != rendered_structures:
		for node: Node3D in structure_nodes.values():
			node.free()
		structure_nodes.clear()
		for slot: String in structures:
			var piece := make_piece(str(structures[slot]["kind"]))
			add_child(piece)
			piece.position = World.Structures.position(World.Structures.cell_for(slot))
			piece.rotation.y = int(structures[slot]["rotation"]) * PI / 2
			structure_nodes[slot] = piece
		rendered_structures = structures.duplicate(true)
	if layout != rendered_layout:
		for node: Node3D in pieces.values():
			node.free()
		pieces.clear()
		for x: int in World.FURNISHING_COLUMNS:
			for z: int in World.FURNISHING_ROWS:
				var key := World.furnishing_cell_key(Vector2i(x, z))
				if not layout.has(key):
					continue
				var piece := make_piece(str(layout[key]["kind"]))
				add_child(piece)
				piece.position = World.furnishing_position(Vector2i(x, z))
				piece.rotation.y = int(layout[key]["rotation"]) * PI / 2.0
				pieces[key] = piece
		rendered_layout = layout.duplicate(true)
	var player_position: Vector3 = snapshot.get("positions", {}).get(token, Vector3.INF)
	var seed_value := int(snapshot.get("world_seed", 1))
	var local_section := World.Wilderness.cell_at(player_position) if player_position.is_finite() else Vector2i(-99, -99)
	_update_remote_plots(snapshot.get("wilderness_plots", {}), seed_value, local_section)
	_update_station_markers(snapshot)
	plot_id = World.Wilderness.key(local_section) if World.Wilderness.valid(local_section) else ""
	var shift := Vector3.ZERO
	var claimed := true
	if not plot_id.is_empty():
		shift = World.Wilderness.plot_origin(seed_value, local_section) - World.FURNISHING_ORIGIN
		var plots: Dictionary = snapshot.get("wilderness_plots", {})
		claimed = plots.has(plot_id)
		layout = plots.get(plot_id, {}).get("furnishings", {})
		structures = plots.get(plot_id, {}).get("structures", {})
	grid.position = shift
	toggle.text = "Build %s (B)" % ("south yard" if plot_id.is_empty() else World.Wilderness.title(local_section))
	var eligible := connected and str(snapshot.get("quest_stage", "")) == "home_repaired"
	eligible = eligible and not bool(snapshot.get("downed_players", {}).get(token, false))
	panel.get_parent().visible = eligible
	if not eligible:
		if active:
			toggle_mode()
		return
	if not active:
		return
	var position := player_position - shift
	if not position.is_finite():
		can_place = false
		can_remove = false
		return
	var aim := position + Vector3(-sin(yaw), 0.0, -cos(yaw)) * 2.0
	var offset := (aim - World.FURNISHING_ORIGIN) / World.FURNISHING_SPACING
	cell = Vector2i(roundi(offset.x), roundi(offset.z))
	var valid := claimed and World.furnishing_cell_valid(cell)
	var target := World.furnishing_position(cell)
	var nearby := position.distance_to(target) <= World.FURNISHING_REACH
	var occupied := layout.has(World.furnishing_cell_key(cell))
	var wood := int(snapshot.get("materials", {}).get("wood", 0))
	var requirement := World.furnishing_requirement(kind, snapshot)
	can_remove = valid and nearby and occupied
	can_place = valid and nearby and not occupied and wood >= World.FURNISHING_WOOD_COST and requirement.is_empty()
	var structure_error := ""
	if kind in World.Structures.KINDS:
		var local_players: Array = []
		for point: Vector3 in snapshot.get("positions", {}).values():
			local_players.append(point - shift)
		structure_error = World.Structures.change_error(structures, cell, kind, quarter_turns, false, local_players)
		can_place = valid and nearby and structure_error.is_empty() and wood >= World.FURNISHING_WOOD_COST
		can_remove = valid and nearby and World.Structures.change_error(structures, cell, kind, quarter_turns, true).is_empty()
	preview.visible = valid
	preview.position = target + shift
	preview.rotation.y = quarter_turns * PI / 2.0
	for child: Node in preview.get_children():
		if child is MeshInstance3D:
			(child.material_override as StandardMaterial3D).albedo_color = Color(0.3, 0.9, 0.65, 0.55) if can_place else Color(0.95, 0.4, 0.3, 0.45)
	place.disabled = not can_place
	remove_button.disabled = not can_remove
	var hint := "Walk toward the plot and look toward a cell."
	if valid and nearby:
		hint = "Occupied · remove to rearrange." if occupied else ("Ready to place." if can_place else "Gather 2 shared wood to build.")
	if not requirement.is_empty():
		hint = "RECIPE LOCKED · " + requirement
	if occupied and kind not in World.Structures.KINDS and snapshot.get("homestead_planted_at", {}).has(plot_id + "/" + World.furnishing_cell_key(cell)):
		hint = "Planted crop · removing discards the crop. Wood is refunded."
	if kind in World.Structures.KINDS and valid and nearby:
		hint = structure_error if not structure_error.is_empty() else ("Ready to build." if can_place else "Gather 2 shared wood to build.")
		if structures.has(World.Structures.key(cell, kind, quarter_turns)):
			hint = "Selected slot occupied · remove to rearrange." if can_remove else World.Structures.change_error(structures, cell, kind, quarter_turns, true)
	choose.text = "%s · change (T)" % _piece_name()
	if not claimed:
		hint = "Protected outpost · no building plot." if local_section == World.Wilderness.outpost_cell(seed_value) else "Claim this clearing at its post · 2 wood. Close build mode to interact."
		grid.visible = false
	else:
		grid.visible = true
	details.text = "SHARED %s\nWood %d · Rotation %d°\n%s\nMove; hold right mouse to look." % ["SOUTH YARD" if plot_id.is_empty() else World.Wilderness.title(local_section).to_upper(), wood, quarter_turns * 90, hint]


func _update_remote_plots(plots: Dictionary, seed_value: int, local_section: Vector2i) -> void:
	for id: String in remote_roots.keys():
		var section := World.Structures.cell_for(id)
		if seed_value != remote_seed or not plots.has(id) or absi(section.x - local_section.x) > 1 or absi(section.y - local_section.y) > 1:
			remote_roots[id].free()
			remote_roots.erase(id)
			remote_layouts.erase(id)
	remote_seed = seed_value
	for id: String in plots:
		var section := World.Structures.cell_for(id)
		if absi(section.x - local_section.x) > 1 or absi(section.y - local_section.y) > 1:
			continue
		if remote_layouts.get(id) == plots[id]:
			continue
		if remote_roots.has(id):
			remote_roots[id].free()
		var root := Node3D.new()
		add_child(root)
		root.position = World.Wilderness.plot_origin(seed_value, section) - World.FURNISHING_ORIGIN
		for category: String in ["furnishings", "structures"]:
			for slot: String in plots[id][category]:
				var data: Dictionary = plots[id][category][slot]
				var piece := make_piece(data["kind"])
				root.add_child(piece)
				piece.position = World.Structures.position(World.Structures.cell_for(slot))
				piece.rotation.y = int(data["rotation"]) * PI / 2
		remote_roots[id] = root
		remote_layouts[id] = plots[id].duplicate(true)


func _piece_name() -> String:
	return str(World.FURNISHING_NAMES.get(kind, World.Structures.NAMES.get(kind, kind)))


func _update_station_markers(snapshot: Dictionary) -> void:
	var needed: Dictionary = {}
	for station: Dictionary in World.furnishing_stations(snapshot):
		if not str(station["plot_id"]).is_empty() and not remote_roots.has(station["plot_id"]):
			continue
		var id: String = station["id"]
		needed[id] = true
		if not station_markers.has(id):
			var marker := Node3D.new()
			add_child(marker)
			var label := Label3D.new()
			label.name = "Label"
			label.position.y = 0.9
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			label.font_size = 32
			label.pixel_size = 0.0015
			label.fixed_size = true
			label.modulate = Color("ebd7ac")
			marker.add_child(label)
			station_markers[id] = marker
		station_markers[id].position = station["position"]
		station_markers[id].get_node("Label").text = station["text"]
		if World.CROP_BEDS.has(station["kind"]):
			_update_crop(station_markers[id], station["kind"], station["crop_phase"])
		elif station_markers[id].has_node("Crop"):
			station_markers[id].get_node("Crop").free()
			station_markers[id].remove_meta("crop_appearance")
	for id: String in station_markers.keys():
		if not needed.has(id):
			station_markers[id].free()
			station_markers.erase(id)


func _update_crop(marker: Node3D, crop_kind: String, phase: String) -> void:
	var appearance := crop_kind + "/" + phase
	if marker.get_meta("crop_appearance", "") == appearance:
		return
	marker.set_meta("crop_appearance", appearance)
	if marker.has_node("Crop"):
		marker.get_node("Crop").free()
	var crop := Node3D.new()
	crop.name = "Crop"
	marker.add_child(crop)
	if phase == "empty":
		return
	var ripe := phase == "ripe"
	for x: float in [-0.6, 0, 0.6]:
		for z: float in [-0.35, 0.35]:
			var height := 0.55 if ripe else 0.2
			_box(crop, Vector3(0.1, height, 0.1), Vector3(x, -0.32 + height / 2, z), Color("669650"))
			_box(crop, Vector3(0.3, 0.18, 0.3), Vector3(x, -0.32 + height, z), Color("b5cee6") if ripe and crop_kind == "moonroot_bed" else (Color("e4bd64") if ripe else Color("80b16a")))


func _rebuild_preview() -> void:
	if preview != null:
		preview.free()
	preview = make_piece(kind)
	add_child(preview)
	preview.visible = active
	for child: Node in preview.get_children():
		if child is MeshInstance3D:
			var material := child.material_override as StandardMaterial3D
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.emission_enabled = false
		elif child is Light3D:
			child.visible = false


static func make_piece(piece_kind: String) -> Node3D:
	var result := Node3D.new()
	if World.CROP_BEDS.has(piece_kind):
		_box(result, Vector3(2.25, 0.2, 1.8), Vector3(0, 0.1, 0), Color("6b5140"))
		for z: float in [-0.9, 0.9]:
			_box(result, Vector3(2.4, 0.3, 0.12), Vector3(0, 0.15, z), Color("a1815c"))
		for x: float in [-1.14, 1.14]:
			_box(result, Vector3(0.12, 0.3, 1.8), Vector3(x, 0.15, 0), Color("a1815c"))
	elif piece_kind == "bedroll":
		_box(result, Vector3(1.15, 0.12, 2), Vector3(0, 0.2, 0), Color("527b79"))
		_box(result, Vector3(0.95, 0.18, 0.4), Vector3(0, 0.32, -0.65), Color("ded3b6"))
		_box(result, Vector3(1.2, 0.18, 1.25), Vector3(0, 0.29, 0.32), Color("849fa0"))
	elif piece_kind == "trailwork_bench":
		_box(result, Vector3(2.1, 0.16, 1.1), Vector3(0, 0.95, 0), Color("967251"))
		for x in [-0.8, 0.8]:
			_box(result, Vector3(0.2, 0.9, 0.8), Vector3(x, 0.45, 0), Color("6d5841"))
		_box(result, Vector3(0.6, 0.16, 0.5), Vector3(-0.4, 1.1, 0), Color("7ba185"))
		_box(result, Vector3(0.4, 0.3, 0.4), Vector3(0.55, 1.2, 0.1), Color("c3a478"))
	elif piece_kind == "foundation":
		_box(result, Vector3(2.8, 0.12, 2.8), Vector3(0, 0.06, 0), Color("ab9470"))
	elif piece_kind in ["wall", "doorway"]:
		if piece_kind == "wall":
			_box(result, Vector3(2.8, 2.4, 0.16), Vector3(0, 1.2, -1.4), Color("9d805b"))
		else:
			for x in [-1.05, 1.05]:
				_box(result, Vector3(0.7, 2.4, 0.16), Vector3(x, 1.2, -1.4), Color("9d805b"))
			_box(result, Vector3(1.4, 0.3, 0.16), Vector3(0, 2.25, -1.4), Color("9d805b"))
	elif piece_kind == "roof":
		_box(result, Vector3(3, 0.16, 3), Vector3(0, 2.52, 0), Color("71867b"))
	elif piece_kind == "bench":
		_box(result, Vector3(2.1, 0.2, 0.7), Vector3(0, 0.65, 0), Color("92704e"))
		_box(result, Vector3(2.1, 0.55, 0.15), Vector3(0, 1.05, 0.3), Color("aa8760"))
		for x: float in [-0.8, 0.8]:
			_box(result, Vector3(0.18, 0.65, 0.6), Vector3(x, 0.325, 0), Color("634d3b"))
	elif piece_kind == "watch_lantern":
		_box(result, Vector3(0.65, 0.2, 0.65), Vector3(0, 0.1, 0), Color("70877f"))
		_box(result, Vector3(0.15, 1.3, 0.15), Vector3(0, 0.8, 0), Color("806448"))
		_box(result, Vector3(0.75, 0.12, 0.65), Vector3(0, 1.9, 0), Color("70877f"))
		var glow := _box(result, Vector3(0.42, 0.48, 0.36), Vector3(0, 1.6, 0), Color("f3d991"))
		(glow.material_override as StandardMaterial3D).emission_enabled = true
		(glow.material_override as StandardMaterial3D).emission = Color("f3d991")
		var light := OmniLight3D.new()
		light.name = "WarmLight"
		light.position = Vector3(0, 1.6, 0)
		light.light_color = Color("ffd694")
		light.omni_range = 4
		result.add_child(light)
	elif piece_kind == "gathering_table":
		_box(result, Vector3(2.2, 0.16, 1.3), Vector3(0, 0.9, 0), Color("92704e"))
		for x: float in [-0.85, 0.85]:
			for z: float in [-0.4, 0.4]:
				_box(result, Vector3(0.16, 0.85, 0.16), Vector3(x, 0.425, z), Color("634d3b"))
		_box(result, Vector3(0.65, 0.03, 1.35), Vector3(0, 1, 0), Color("b7b0d9"))
		for x: float in [-0.7, 0.7]:
			_box(result, Vector3(0.4, 0.06, 0.4), Vector3(x, 1.02, 0), Color("e6dcc0"))
	else:
		_box(result, Vector3(1.8, 0.55, 0.8), Vector3(0, 0.275, 0), Color("967559"))
		_box(result, Vector3(1.6, 0.1, 0.65), Vector3(0, 0.55, 0), Color("446544"))
		for x: float in [-0.6, 0.0, 0.6]:
			_box(result, Vector3(0.08, 0.4, 0.08), Vector3(x, 0.8, 0), Color("69905a"))
			_box(result, Vector3(0.38, 0.2, 0.38), Vector3(x, 1.0, 0), Color("d9b0d1"))
	return result


static func _box(parent: Node3D, size: Vector3, position: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	node.material_override = material
	node.position = position
	parent.add_child(node)
	return node

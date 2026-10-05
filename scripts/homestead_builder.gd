extends Node3D

const World = preload("res://scripts/world_state.gd")
signal change_requested(cell: Vector2i, kind: String, quarter_turns: int, remove: bool)
signal mode_changed(active: bool)

var active := false
var kind := "bench"
var quarter_turns := 0
var cell := Vector2i(-1, -1)
var can_place := false
var can_remove := false
var pieces: Dictionary = {}
var rendered_layout: Dictionary = {}
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
	kind = "flower_box" if kind == "bench" else "bench"
	choose.text = "%s · change (T)" % ("Bench" if kind == "bench" else "Flower box")
	_rebuild_preview()


func rotate_piece() -> void:
	quarter_turns = (quarter_turns + 1) % 4


func request_change(remove: bool) -> void:
	if active and ((remove and can_remove) or (not remove and can_place)):
		change_requested.emit(cell, kind, quarter_turns, remove)


func update_view(snapshot: Dictionary, token: String, yaw: float, connected: bool) -> void:
	var layout: Dictionary = snapshot.get("furnishings", {})
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
	var eligible := connected and str(snapshot.get("quest_stage", "")) == "home_repaired"
	eligible = eligible and not bool(snapshot.get("downed_players", {}).get(token, false))
	panel.get_parent().visible = eligible
	if not eligible:
		if active:
			toggle_mode()
		return
	if not active:
		return
	var position: Vector3 = snapshot.get("positions", {}).get(token, Vector3.INF)
	if not position.is_finite():
		can_place = false
		can_remove = false
		return
	var aim := position + Vector3(-sin(yaw), 0.0, -cos(yaw)) * 2.0
	var offset := (aim - World.FURNISHING_ORIGIN) / World.FURNISHING_SPACING
	cell = Vector2i(roundi(offset.x), roundi(offset.z))
	var valid := World.furnishing_cell_valid(cell)
	var target := World.furnishing_position(cell)
	var nearby := position.distance_to(target) <= World.FURNISHING_REACH
	var occupied := layout.has(World.furnishing_cell_key(cell))
	var wood := int(snapshot.get("materials", {}).get("wood", 0))
	can_remove = valid and nearby and occupied
	can_place = valid and nearby and not occupied and wood >= World.FURNISHING_WOOD_COST
	preview.visible = valid
	preview.position = target
	preview.rotation.y = quarter_turns * PI / 2.0
	for mesh: MeshInstance3D in preview.get_children():
		(mesh.material_override as StandardMaterial3D).albedo_color = Color(0.3, 0.9, 0.65, 0.55) if can_place else Color(0.95, 0.4, 0.3, 0.45)
	place.disabled = not can_place
	remove_button.disabled = not can_remove
	var hint := "Walk to the south yard and look toward a cell."
	if valid and nearby:
		hint = "Occupied · remove to rearrange." if occupied else ("Ready to place." if can_place else "Gather 2 shared wood to build.")
	details.text = "SHARED SOUTH YARD\nWood %d · Rotation %d°\n%s\nMove; hold right mouse to look." % [wood, quarter_turns * 90, hint]


func _rebuild_preview() -> void:
	if preview != null:
		preview.free()
	preview = make_piece(kind)
	add_child(preview)
	preview.visible = active
	for mesh: MeshInstance3D in preview.get_children():
		var material := mesh.material_override as StandardMaterial3D
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA


static func make_piece(piece_kind: String) -> Node3D:
	var result := Node3D.new()
	if piece_kind == "bench":
		_box(result, Vector3(2.1, 0.2, 0.7), Vector3(0, 0.65, 0), Color("92704e"))
		_box(result, Vector3(2.1, 0.55, 0.15), Vector3(0, 1.05, 0.3), Color("aa8760"))
		for x: float in [-0.8, 0.8]:
			_box(result, Vector3(0.18, 0.65, 0.6), Vector3(x, 0.325, 0), Color("634d3b"))
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

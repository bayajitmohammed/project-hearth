extends CanvasLayer

const Catalog = preload("res://scripts/activity_catalog.gd")
signal pin_requested(activity_id: String)
signal mode_changed(active: bool)
var active := false
var release_pending := false
var available := false
var launcher: Button
var overlay: Control
var list: VBoxContainer
var automatic: Button
var rows: Dictionary = {}
var entry_ids: Array = []
var selected := "automatic"


func _ready() -> void:
	layer = 20
	launcher = Button.new()
	launcher.text = "Activity journal (J)"
	launcher.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	launcher.position = Vector2(-292, 104)
	launcher.size = Vector2(272, 40)
	launcher.pressed.connect(toggle_mode)
	add_child(launcher)
	launcher.visible = false
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.04, 0.06, 0.8)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)
	var card := PanelContainer.new()
	card.anchor_left = 0.12
	card.anchor_right = 0.88
	card.anchor_top = 0.07
	card.anchor_bottom = 0.93
	var style := StyleBoxFlat.new()
	style.bg_color = Color("192d36")
	style.border_color = Color("a6c7b8")
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(20)
	card.add_theme_stylebox_override("panel", style)
	overlay.add_child(card)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	card.add_child(content)
	var heading := Label.new()
	heading.text = "YOUR NEXT ADVENTURE"
	heading.add_theme_font_size_override("font_size", 24)
	content.add_child(heading)
	var subtitle := Label.new()
	subtitle.text = "Pin guidance for yourself. Friends keep their own goals. The world keeps running."
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(subtitle)
	var actions := HBoxContainer.new()
	content.add_child(actions)
	automatic = Button.new()
	automatic.text = "Use automatic guidance"
	automatic.custom_minimum_size.y = 40
	automatic.pressed.connect(func() -> void: pin_requested.emit("automatic"))
	actions.add_child(automatic)
	var close := Button.new()
	close.text = "Back to world (J / Esc)"
	close.custom_minimum_size.y = 40
	close.pressed.connect(toggle_mode)
	actions.add_child(close)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(scroll)
	list = VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 14)
	scroll.add_child(list)
	overlay.visible = false


func _input(event: InputEvent) -> void:
	if not available:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_J or (event.keycode == KEY_ESCAPE and active):
			toggle_mode()
			get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if release_pending and not Input.is_anything_pressed():
		release_pending = false


func blocks_gameplay() -> bool:
	return active or release_pending


func toggle_mode() -> void:
	if not available and not active:
		return
	active = not active
	overlay.visible = active
	launcher.visible = available and not active
	release_pending = true
	if active:
		automatic.grab_focus()
	else:
		get_viewport().gui_release_focus()
	mode_changed.emit(active)


func update_view(snapshot: Dictionary, token: String, connected: bool) -> void:
	available = connected
	if not available and active:
		toggle_mode()
	launcher.visible = available and not active
	selected = str(snapshot.get("player_activity_pins", {}).get(token, "automatic"))
	automatic.text = "Automatic guidance (selected)" if selected == "automatic" else "Use automatic guidance"
	var entries := Catalog.entries(snapshot)
	var ids: Array = []
	for entry: Dictionary in entries:
		ids.append(entry["id"])
	if ids != entry_ids:
		for child: Node in list.get_children():
			child.free()
		rows.clear()
		entry_ids = ids
		for entry: Dictionary in entries:
			var row := VBoxContainer.new()
			list.add_child(row)
			var title := Label.new()
			title.add_theme_font_size_override("font_size", 19)
			row.add_child(title)
			var details := Label.new()
			details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			row.add_child(details)
			var pin := Button.new()
			pin.custom_minimum_size.y = 38
			pin.pressed.connect(func() -> void: pin_requested.emit(str(entry["id"])))
			row.add_child(pin)
			rows[entry["id"]] = {"title": title, "details": details, "pin": pin}
	for entry: Dictionary in entries:
		var row: Dictionary = rows[entry["id"]]
		row["title"].text = "%s · %s%s" % [entry["title"], entry["category"], " · Complete" if entry["complete"] else ""]
		row["details"].text = "%s\n%s" % [entry["objective"], entry["description"]]
		row["pin"].text = "Pinned for you" if entry["id"] == selected else "Pin this activity"

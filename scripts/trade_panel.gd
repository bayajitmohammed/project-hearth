extends CanvasLayer

const Rules = preload("res://scripts/personal_trades.gd")
signal command_requested(command: Dictionary)
signal mode_changed(active: bool)
var active := false
var release_pending := false
var available := false
var launcher: Button
var overlay: Control
var balance: Label
var status: Label
var terms: Label
var recipient: OptionButton
var give: OptionButton
var take: OptionButton
var give_count: SpinBox
var take_count: SpinBox
var propose: Button
var accept: Button
var cancel: Button
var draft: VBoxContainer
var peers: Array = []
var offer_id := -1


func _ready() -> void:
	layer = 21
	launcher = Button.new()
	launcher.text = "Trade (Y)"
	launcher.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	launcher.position = Vector2(-292, 150)
	launcher.size = Vector2(272, 40)
	launcher.pressed.connect(toggle_mode)
	add_child(launcher)
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.04, 0.06, 0.85)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)
	var card := PanelContainer.new()
	card.anchor_left = 0.2
	card.anchor_right = 0.8
	card.anchor_top = 0.12
	card.anchor_bottom = 0.88
	var style := StyleBoxFlat.new()
	style.bg_color = Color("192d36")
	style.set_content_margin_all(20)
	style.set_corner_radius_all(12)
	card.add_theme_stylebox_override("panel", style)
	overlay.add_child(card)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	card.add_child(content)
	_label(content, "TRADE PERSONAL GOODS", 24)
	_label(content, "Stay within 3 metres. The world keeps running. Shared materials are never traded.")
	balance = _label(content, "")
	status = _label(content, "")
	draft = VBoxContainer.new()
	content.add_child(draft)
	_label(draft, "Companion nearby")
	recipient = OptionButton.new()
	draft.add_child(recipient)
	var outgoing := HBoxContainer.new()
	draft.add_child(outgoing)
	_label(outgoing, "You give")
	give = _items(outgoing)
	give_count = _quantity(outgoing)
	var incoming := HBoxContainer.new()
	draft.add_child(incoming)
	_label(incoming, "You receive")
	take = _items(incoming)
	take.select(1)
	take_count = _quantity(incoming)
	propose = _button(draft, "Send these exact terms", func() -> void:
		if recipient.selected >= 0 and recipient.selected < peers.size():
			command_requested.emit({"action": "propose", "to": peers[recipient.selected], "give": Rules.ITEMS[give.selected], "give_count": int(give_count.value), "take": Rules.ITEMS[take.selected], "take_count": int(take_count.value)})
	)
	terms = _label(content, "", 22)
	accept = _button(content, "Accept this exact exchange", func() -> void: command_requested.emit({"action": "accept", "id": offer_id}))
	cancel = _button(content, "Decline / cancel offer", func() -> void: command_requested.emit({"action": "cancel", "id": offer_id}))
	_button(content, "Back to world (Y / Esc)", toggle_mode)
	overlay.visible = false
	launcher.visible = false


func _label(parent: Node, text: String, size: int = 17) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	label.custom_minimum_size.x = 100
	parent.add_child(label)
	return label


func _items(parent: Node) -> OptionButton:
	var select := OptionButton.new()
	for kind: String in Rules.ITEMS:
		select.add_item(Rules.NAMES[kind])
	select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(select)
	return select


func _quantity(parent: Node) -> SpinBox:
	var spin := SpinBox.new()
	spin.min_value = 1
	spin.max_value = 99
	spin.value = 1
	spin.custom_minimum_size.x = 110
	parent.add_child(spin)
	return spin


func _button(parent: Node, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 40
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _input(event: InputEvent) -> void:
	if available and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_Y or (event.keycode == KEY_ESCAPE and active):
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
	get_viewport().gui_release_focus()
	mode_changed.emit(active)


func update_view(snapshot: Dictionary, token: String, connected: bool) -> void:
	available = connected
	if not available and active:
		toggle_mode()
	launcher.visible = available and not active
	var trading: Dictionary = snapshot.get("trades", {})
	var offer: Dictionary = {}
	for candidate: Dictionary in trading.get("offers", {}).values():
		if candidate["from"] == token or candidate["to"] == token:
			offer = candidate
	var pending := not offer.is_empty()
	offer_id = int(offer.get("id", -1))
	launcher.text = "Trade offer received (Y)" if pending and offer["to"] == token else "Trade (Y)"
	balance.text = "You carry: %d coin · %d riverfish · %d trail provisions" % [int(snapshot.get("player_coins", {}).get(token, 0)), int(snapshot.get("player_riverfish", {}).get(token, 0)), int(snapshot.get("player_provisions", {}).get(token, 0))]
	status.text = str(trading.get("messages", {}).get(token, "Choose a companion and propose an exchange. No goods move before acceptance."))
	draft.visible = not pending
	terms.visible = pending
	accept.visible = pending and offer.get("to", "") == token
	cancel.visible = pending
	if pending:
		var sender: bool = offer["from"] == token
		terms.text = "Companion: %s\nYOU GIVE: %d %s\nYOU RECEIVE: %d %s\nOffer #%d · expires in %.0fs%s" % [str(offer["to"] if sender else offer["from"]), int(offer["give_count"] if sender else offer["take_count"]), Rules.NAMES[offer["give"] if sender else offer["take"]], int(offer["take_count"] if sender else offer["give_count"]), Rules.NAMES[offer["take"] if sender else offer["give"]], offer_id, float(offer["remaining"]), "\nWaiting for your companion's acceptance." if sender else ""]
	var nearby: Array = []
	var positions: Dictionary = snapshot.get("positions", {})
	for peer: String in positions:
		if peer != token and positions.has(token) and positions[token].distance_to(positions[peer]) <= Rules.REACH and not bool(snapshot.get("downed_players", {}).get(peer, false)):
			nearby.append(peer)
	nearby.sort()
	if nearby != peers:
		peers = nearby
		recipient.clear()
		for peer: String in peers:
			recipient.add_item(peer)
	propose.disabled = peers.is_empty() or bool(snapshot.get("downed_players", {}).get(token, false))
	if peers.is_empty() and not pending:
		status.text = "No standing companion within 3 metres. Solo play never requires trading."

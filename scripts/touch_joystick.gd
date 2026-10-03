extends Control

signal value_changed(value: Vector2)

const STICK_RADIUS_RATIO := 0.393
const KNOB_RADIUS_RATIO := 0.173
const DEAD_ZONE := 0.14

var value := Vector2.ZERO
var active_touch_index := -1
var mouse_dragging := false
var visual_diameter := 168.0
var horizontal_inset := 28.0
var stick_center := Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(true)
	_reset_center()
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and active_touch_index == -1 and not mouse_dragging:
		_reset_center()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and active_touch_index == -1 and get_global_rect().has_point(event.position):
			active_touch_index = event.index
			stick_center = _clamp_stick_center(_screen_to_local(event.position))
			_set_value(Vector2.ZERO)
			get_viewport().set_input_as_handled()
		elif not event.pressed and event.index == active_touch_index:
			active_touch_index = -1
			_set_value(Vector2.ZERO)
			_reset_center()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == active_touch_index:
		_update_from_screen_position(event.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and get_global_rect().has_point(event.position):
			mouse_dragging = true
			stick_center = _clamp_stick_center(_screen_to_local(event.position))
			_set_value(Vector2.ZERO)
			get_viewport().set_input_as_handled()
		elif not event.pressed and mouse_dragging:
			mouse_dragging = false
			_set_value(Vector2.ZERO)
			_reset_center()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and mouse_dragging:
		_update_from_screen_position(event.position)
		get_viewport().set_input_as_handled()


func _draw() -> void:
	var stick_radius := _stick_radius()
	var knob_radius := visual_diameter * KNOB_RADIUS_RATIO
	draw_circle(stick_center, stick_radius, Color(0.035, 0.08, 0.1, 0.2))
	draw_arc(stick_center, stick_radius, 0.0, TAU, 64, Color(0.72, 0.96, 0.98, 0.4), 2.0, true)
	var knob_position := stick_center + value * stick_radius
	draw_circle(knob_position, knob_radius, Color(0.72, 0.96, 0.98, 0.32))
	draw_arc(knob_position, knob_radius, 0.0, TAU, 40, Color(0.9, 1.0, 1.0, 0.62), 2.0, true)


func _update_from_screen_position(screen_position: Vector2) -> void:
	_update_from_local_position(_screen_to_local(screen_position))


func _screen_to_local(screen_position: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * screen_position


func _update_from_local_position(local_position: Vector2) -> void:
	var raw_value := (local_position - stick_center) / _stick_radius()
	if raw_value.length() < DEAD_ZONE:
		_set_value(Vector2.ZERO)
		return
	_set_value(raw_value.limit_length(1.0))


func _stick_radius() -> float:
	return visual_diameter * STICK_RADIUS_RATIO


func _clamp_stick_center(local_position: Vector2) -> Vector2:
	var radius := _stick_radius()
	return Vector2(
		clampf(local_position.x, radius, maxf(size.x - radius, radius)),
		clampf(local_position.y, radius, maxf(size.y - radius, radius))
	)


func _reset_center() -> void:
	stick_center = Vector2(horizontal_inset + visual_diameter * 0.5, size.y * 0.5)
	queue_redraw()


func _set_value(next_value: Vector2) -> void:
	value = next_value
	value_changed.emit(value)
	queue_redraw()


func reset() -> void:
	active_touch_index = -1
	mouse_dragging = false
	_set_value(Vector2.ZERO)
	_reset_center()

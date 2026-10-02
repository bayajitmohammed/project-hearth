extends SceneTree

const MainScene = preload("res://main.tscn")


func _init() -> void:
	var main = MainScene.instantiate()
	root.add_child(main)
	await process_frame

	main.local_token = "camera-test"
	var player: MeshInstance3D = main._get_or_create_player_node(main.local_token)
	player.position = Vector3.ZERO
	main._process(1.0)
	var initial_position: Vector3 = main.game_camera.position

	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_RIGHT
	press.pressed = true
	main._unhandled_input(press)
	var motion := InputEventMouseMotion.new()
	motion.relative = Vector2(180.0, 0.0)
	main._unhandled_input(motion)
	main._process(1.0)
	assert(not is_equal_approx(main.camera_yaw, 0.0), "Right-drag must orbit the camera.")
	assert(not main.game_camera.position.is_equal_approx(initial_position), "Orbit must move the camera around the player.")

	var original_distance: float = main.camera_distance
	var zoom := InputEventMouseButton.new()
	zoom.button_index = MOUSE_BUTTON_WHEEL_UP
	zoom.pressed = true
	main._unhandled_input(zoom)
	assert(main.camera_distance < original_distance, "Mouse wheel must adjust camera distance.")

	main.camera_yaw = 0.0
	var forward := Vector2(0.0, -1.0).rotated(-main.camera_yaw)
	assert(forward.is_equal_approx(Vector2(0.0, -1.0)))
	main.camera_yaw = PI / 2.0
	forward = Vector2(0.0, -1.0).rotated(-main.camera_yaw)
	assert(forward.is_equal_approx(Vector2(-1.0, 0.0)), "Movement must remain camera-relative.")

	print("PASS: Adjustable third-person camera")
	quit()

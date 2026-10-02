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
	assert(main.camera_mode == main.CAMERA_FIRST_PERSON)
	assert(not player.visible, "The local body must be hidden in first person.")
	assert(main.game_camera.position.is_equal_approx(Vector3(0.0, 0.62, 0.0)), "First person must place the camera at eye level.")

	var motion := InputEventMouseMotion.new()
	motion.relative = Vector2(180.0, 0.0)
	main._unhandled_input(motion)
	main._process(1.0)
	assert(not is_equal_approx(main.camera_yaw, 0.0), "Mouse movement must turn the camera without holding a button.")

	var pitch_before_downward_drag: float = main.camera_pitch
	var downward_motion := InputEventMouseMotion.new()
	downward_motion.relative = Vector2(0.0, 40.0)
	main._unhandled_input(downward_motion)
	assert(
		main.camera_pitch > pitch_before_downward_drag,
		"Dragging downward must tilt the view downward."
	)

	main.camera_yaw = 0.0
	main.camera_pitch = 0.0
	main._toggle_camera_mode()
	main._process(1.0)
	assert(main.camera_mode == main.CAMERA_THIRD_PERSON)
	assert(player.visible, "The local body must be visible in third person.")
	assert(main.game_camera.position.z > player.position.z, "The third-person camera must sit behind the player.")
	assert(main.game_camera.position.x > player.position.x, "The third-person camera must use an over-the-shoulder offset.")
	assert(main.game_camera.position.y - player.position.y < 2.0, "Third person must stay near shoulder level, not top-down.")

	var original_distance: float = main.camera_distance
	var zoom := InputEventMouseButton.new()
	zoom.button_index = MOUSE_BUTTON_WHEEL_UP
	zoom.pressed = true
	main._unhandled_input(zoom)
	assert(main.camera_distance < original_distance, "Mouse wheel must adjust camera distance.")
	assert(InputMap.has_action("toggle_camera"), "Camera switching needs a mapped input action.")

	main._toggle_camera_mode()
	main._process(1.0)
	assert(main.camera_mode == main.CAMERA_FIRST_PERSON)
	assert(not player.visible)

	main.camera_yaw = 0.0
	var forward := Vector2(0.0, -1.0).rotated(-main.camera_yaw)
	assert(forward.is_equal_approx(Vector2(0.0, -1.0)))
	main.camera_yaw = PI / 2.0
	forward = Vector2(0.0, -1.0).rotated(-main.camera_yaw)
	assert(forward.is_equal_approx(Vector2(-1.0, 0.0)), "Movement must remain camera-relative.")

	print("PASS: Switchable first-person and over-the-shoulder camera")
	quit()

extends SceneTree

const MainScene = preload("res://main.tscn")
const Graybox = preload("res://scripts/graybox_world.gd")


func _init() -> void:
	var main = MainScene.instantiate()
	root.add_child(main)
	main.local_input_enabled = false
	var deadline := Time.get_ticks_msec() + 15000
	while main.latest_snapshot.get("positions", {}).size() < 2:
		if Time.get_ticks_msec() >= deadline:
			push_error("Timed out waiting for both seeded-world clients")
			quit(1)
			return
		await create_timer(0.05).timeout
	assert(int(main.latest_snapshot["world_seed"]) == 112358)
	assert(main.rendered_world_seed == 112358)
	var reference := Graybox.create_northern_region(main, 112358)
	var actual: Array = []
	var expected: Array = []
	for child: Node3D in main.northern_region.get_children():
		actual.append(child.transform)
	for child: Node3D in reference.get_children():
		expected.append(child.transform)
	assert(actual == expected, "Joined clients must render the authority's saved world seed.")
	reference.free()
	print("PASS: world seed synchronized and generated scenery matched for %s" % main.local_token)
	await create_timer(0.5).timeout
	quit()

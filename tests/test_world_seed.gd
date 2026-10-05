extends SceneTree

const World = preload("res://scripts/world_state.gd")
const Graybox = preload("res://scripts/graybox_world.gd")


func _init() -> void:
	var a := World.new()
	a.world_seed = 112358
	var restored := World.new()
	restored.load_dictionary(a.to_dictionary())
	assert(restored.world_seed == 112358)
	assert(restored.world_weather() == a.world_weather())
	assert(restored.daily_survey_position() == a.daily_survey_position())
	var old := World.new()
	old.load_dictionary({"version": 24})
	assert(old.world_seed == World.REGION_SEED)
	old.load_dictionary({"version": 25, "world_seed": -3})
	assert(old.world_seed == World.REGION_SEED)
	var holder := Node3D.new()
	root.add_child(holder)
	var first := Graybox.create_northern_region(holder, a.world_seed)
	var second := Graybox.create_northern_region(holder, restored.world_seed)
	var different := Graybox.create_northern_region(holder, 271828)
	assert(_layout(first) == _layout(second), "Companions loading one seed must generate identical scenery.")
	assert(_layout(first) != _layout(different), "Distinct seeds must vary the region.")
	first.free()
	second.free()
	different.free()
	print("PASS: persistent world seeds and deterministic region scenery")
	quit()


func _layout(region: Node3D) -> Array:
	var result: Array = []
	for child: Node3D in region.get_children():
		result.append(child.transform)
	return result

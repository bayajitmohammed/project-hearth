class_name GrayboxWorld
extends RefCounted

const WorldStateModel = preload("res://scripts/world_state.gd")


static func build(root: Node3D) -> Dictionary:
	_add_environment(root)
	_add_ground(root)
	_add_road(root)
	_add_cottage(root)
	_add_forest_edge(root)
	_add_landmark_signs(root)
	var mara := _add_mara(root)
	var resource_nodes := _add_resources(root)
	var repair_nodes := _add_repair_markers(root)
	var repair_result_nodes := _add_repair_results(root)
	var welcome_lanterns := _add_welcome_lanterns(root)
	var creature := _add_creature(root)
	var rumor_marker := _add_rumor_marker(root)

	var supplies := _add_box(
		root,
		"LostSupplies",
		Vector3(0.9, 0.8, 0.9),
		WorldStateModel.COLLECTIBLE_POSITION,
		Color("e8ad45")
	)
	var supplies_material := supplies.material_override as StandardMaterial3D
	supplies_material.emission_enabled = true
	supplies_material.emission = Color("6f4213")

	var camera := Camera3D.new()
	camera.name = "PlayerCamera"
	camera.position = WorldStateModel.SPAWN_POINT + Vector3(0.0, 13.0, 11.0)
	camera.rotation_degrees = Vector3(-48.0, 0.0, 0.0)
	camera.current = true
	root.add_child(camera)

	return {
		"collectible": supplies,
		"camera": camera,
		"mara": mara,
		"resources": resource_nodes,
		"repairs": repair_nodes,
		"repair_results": repair_result_nodes,
		"welcome_lantern_markers": welcome_lanterns["markers"],
		"welcome_lantern_lights": welcome_lanterns["lights"],
		"creature": creature,
		"rumor_marker": rumor_marker,
	}


static func _add_environment(root: Node3D) -> void:
	var environment := WorldEnvironment.new()
	var resource := Environment.new()
	resource.background_mode = Environment.BG_COLOR
	resource.background_color = Color("91c8dd")
	resource.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	resource.ambient_light_color = Color("fff4dc")
	resource.ambient_light_energy = 0.72
	environment.environment = resource
	root.add_child(environment)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55.0, -25.0, 0.0)
	light.shadow_enabled = true
	root.add_child(light)


static func _add_ground(root: Node3D) -> void:
	_add_box(root, "Grass", Vector3(36.0, 0.25, 30.0), Vector3(0.0, -0.125, 0.0), Color("78a95e"))
	_add_box(root, "ForestGround", Vector3(36.0, 0.08, 8.0), Vector3(0.0, 0.04, -11.0), Color("4f7d4a"))


static func _add_road(root: Node3D) -> void:
	_add_box(root, "ArrivalRoad", Vector3(5.0, 0.06, 30.0), Vector3(0.0, 0.04, 0.0), Color("a58d70"))
	_add_box(root, "CottagePath", Vector3(7.0, 0.065, 2.0), Vector3(-5.5, 0.045, 3.0), Color("b7a180"))
	for z_position: float in [-8.0, -2.0, 4.0, 10.0]:
		_add_box(root, "RoadStone", Vector3(0.18, 0.03, 2.2), Vector3(0.0, 0.09, z_position), Color("d1c2a8"))


static func _add_cottage(root: Node3D) -> void:
	var cottage_center := Vector3(-10.0, 0.0, 3.0)
	_add_box(root, "CottageFloor", Vector3(7.0, 0.3, 6.0), cottage_center + Vector3(0.0, 0.15, 0.0), Color("826249"))
	_add_box(root, "CottageBack", Vector3(7.0, 3.2, 0.35), cottage_center + Vector3(0.0, 1.8, -2.85), Color("d9c49b"))
	_add_box(root, "CottageLeft", Vector3(0.35, 3.2, 5.4), cottage_center + Vector3(-3.3, 1.8, 0.0), Color("d9c49b"))
	_add_box(root, "CottageRight", Vector3(0.35, 3.2, 5.4), cottage_center + Vector3(3.3, 1.8, 0.0), Color("d9c49b"))
	_add_box(root, "CottageFrontLeft", Vector3(2.4, 3.2, 0.35), cottage_center + Vector3(-2.15, 1.8, 2.85), Color("d9c49b"))
	_add_box(root, "CottageFrontRight", Vector3(2.4, 3.2, 0.35), cottage_center + Vector3(2.15, 1.8, 2.85), Color("d9c49b"))
	_add_box(root, "CottageRoof", Vector3(7.8, 0.5, 6.8), cottage_center + Vector3(0.0, 3.7, 0.0), Color("704d43"))
	_add_box(root, "BrokenDoor", Vector3(1.5, 2.3, 0.18), cottage_center + Vector3(-0.55, 1.3, 2.72), Color("694a36"), Vector3(0.0, 0.0, 12.0))
	_add_box(root, "RepairPlot", Vector3(8.5, 0.08, 7.5), cottage_center + Vector3(0.0, 0.05, 0.0), Color("d9ba62"))


static func _add_forest_edge(root: Node3D) -> void:
	var random := RandomNumberGenerator.new()
	random.seed = 314159
	for index: int in 10:
		var side := -1.0 if index % 2 == 0 else 1.0
		var x_position := side * random.randf_range(4.5, 15.5)
		var z_position := random.randf_range(-12.8, -8.7)
		_add_tree(root, "Tree%d" % index, Vector3(x_position, 0.0, z_position))


static func _add_tree(root: Node3D, tree_name: String, tree_position: Vector3) -> void:
	var trunk := _add_cylinder(root, tree_name + "Trunk", 0.35, 2.7, tree_position + Vector3(0.0, 1.35, 0.0), Color("76533c"))
	trunk.rotation_degrees.y = float(tree_name.hash() % 30)
	_add_cylinder(root, tree_name + "Crown", 1.35, 2.8, tree_position + Vector3(0.0, 3.4, 0.0), Color("376c46"), 6)


static func _add_landmark_signs(root: Node3D) -> void:
	_add_sign(root, "CottageSign", Vector3(-3.2, 0.0, 4.0), Color("e3bd68"))
	_add_sign(root, "ForestSign", Vector3(2.0, 0.0, -6.7), Color("77b879"))


static func _add_mara(root: Node3D) -> Node3D:
	var routine := Node3D.new()
	routine.name = "MaraRoutine"
	routine.position = WorldStateModel.MARA_POSITION
	root.add_child(routine)

	var body := MeshInstance3D.new()
	body.name = "Mara"
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.42
	body_mesh.height = 1.35
	body.mesh = body_mesh
	body.material_override = _material(Color("b45b72"))
	routine.add_child(body)

	var name_label := Label3D.new()
	name_label.name = "MaraName"
	name_label.text = "Mara"
	name_label.position = Vector3(0.0, 1.25, 0.0)
	name_label.font_size = 36
	name_label.outline_size = 8
	name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	routine.add_child(name_label)
	return routine


static func _add_resources(root: Node3D) -> Dictionary:
	var nodes := {}
	for resource_id: String in WorldStateModel.RESOURCE_POSITIONS:
		var resource_type: String = WorldStateModel.RESOURCE_TYPES[resource_id]
		var node: MeshInstance3D
		if resource_type == "wood":
			node = _add_box(
				root, resource_id, Vector3(1.2, 0.45, 0.55),
				WorldStateModel.RESOURCE_POSITIONS[resource_id], Color("8a5c3b"), Vector3(0.0, 20.0, 0.0)
			)
		else:
			node = _add_cylinder(
				root, resource_id, 0.32, 0.55,
				WorldStateModel.RESOURCE_POSITIONS[resource_id], Color("79d06d"), 6
			)
		nodes[resource_id] = node
	return nodes


static func _add_repair_markers(root: Node3D) -> Dictionary:
	var nodes := {}
	for part_id: String in WorldStateModel.REPAIR_POSITIONS:
		var marker := Node3D.new()
		marker.name = "Repair_%s" % part_id
		marker.position = WorldStateModel.REPAIR_POSITIONS[part_id]
		root.add_child(marker)

		var disc := _add_cylinder(marker, "Disc", 0.72, 0.14, Vector3(0.0, -0.48, 0.0), Color("20e0f0"), 20)
		var disc_material := disc.material_override as StandardMaterial3D
		disc_material.emission_enabled = true
		disc_material.emission = Color("20e0f0")
		disc_material.emission_energy_multiplier = 2.0

		var beacon := _add_cylinder(marker, "Beacon", 0.09, 1.5, Vector3(0.0, 0.3, 0.0), Color("e9feff"), 12)
		var beacon_material := beacon.material_override as StandardMaterial3D
		beacon_material.emission_enabled = true
		beacon_material.emission = Color("20e0f0")
		beacon_material.emission_energy_multiplier = 2.5

		var label := Label3D.new()
		label.name = "Label"
		label.text = "REPAIR %s" % WorldStateModel.REPAIR_LABELS[part_id]
		label.position = Vector3(0.0, 1.35, 0.0)
		label.font_size = 48
		label.pixel_size = 0.008
		label.outline_size = 10
		label.modulate = Color("e9feff")
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		marker.add_child(label)

		marker.visible = false
		nodes[part_id] = marker
	return nodes


static func _add_repair_results(root: Node3D) -> Dictionary:
	var nodes := {
		"door": _add_box(root, "RepairedDoor", Vector3(1.5, 2.3, 0.22), Vector3(-10.0, 1.3, 5.78), Color("4e7a58")),
		"wall": _add_box(root, "RepairedWall", Vector3(0.22, 2.0, 1.7), Vector3(-13.48, 1.25, 3.0), Color("e6d6ae")),
		"garden": _add_box(root, "GardenPlanter", Vector3(2.4, 0.5, 1.2), Vector3(-7.0, 0.3, 0.3), Color("6c8f4f")),
	}
	for node: MeshInstance3D in nodes.values():
		node.visible = false
	return nodes


static func _add_welcome_lanterns(root: Node3D) -> Dictionary:
	var markers := {}
	var lights := {}
	for lantern_id: String in WorldStateModel.WELCOME_LANTERN_POSITIONS:
		var marker := Node3D.new()
		marker.name = "WelcomeLanternMarker_%s" % lantern_id
		marker.position = WorldStateModel.WELCOME_LANTERN_POSITIONS[lantern_id]
		root.add_child(marker)
		var disc := _add_cylinder(marker, "Disc", 0.65, 0.12, Vector3(0.0, -0.48, 0.0), Color("f2a93b"), 20)
		var disc_material := disc.material_override as StandardMaterial3D
		disc_material.emission_enabled = true
		disc_material.emission = Color("f2a93b")
		disc_material.emission_energy_multiplier = 1.8
		var label := Label3D.new()
		label.name = "Label"
		label.text = "LIGHT %s" % WorldStateModel.WELCOME_LANTERN_LABELS[lantern_id]
		label.position = Vector3(0.0, 1.25, 0.0)
		label.font_size = 42
		label.pixel_size = 0.008
		label.outline_size = 10
		label.modulate = Color("fff0ba")
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		marker.add_child(label)
		marker.visible = false
		markers[lantern_id] = marker

		var lantern := Node3D.new()
		lantern.name = "WelcomeLantern_%s" % lantern_id
		lantern.position = WorldStateModel.WELCOME_LANTERN_POSITIONS[lantern_id]
		root.add_child(lantern)
		_add_box(lantern, "Post", Vector3(0.16, 1.8, 0.16), Vector3(0.0, 0.3, 0.0), Color("614634"))
		var flame := _add_cylinder(lantern, "Glow", 0.28, 0.5, Vector3(0.0, 1.25, 0.0), Color("ffd66b"), 12)
		var flame_material := flame.material_override as StandardMaterial3D
		flame_material.emission_enabled = true
		flame_material.emission = Color("ffb52e")
		flame_material.emission_energy_multiplier = 3.0
		lantern.visible = false
		lights[lantern_id] = lantern
	return {"markers": markers, "lights": lights}


static func _add_creature(root: Node3D) -> MeshInstance3D:
	var creature := MeshInstance3D.new()
	creature.name = "ForestCreature"
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.55
	mesh.height = 1.2
	creature.mesh = mesh
	creature.position = WorldStateModel.CREATURE_SPAWN
	creature.material_override = _material(Color("7652a6"))
	root.add_child(creature)
	return creature


static func _add_rumor_marker(root: Node3D) -> MeshInstance3D:
	var marker := _add_cylinder(root, "MapRumor", 0.38, 1.5, Vector3(0.0, 0.8, -12.5), Color("62c4d8"), 6)
	var material := marker.material_override as StandardMaterial3D
	material.emission_enabled = true
	material.emission = Color("1a6675")
	marker.visible = false
	return marker


static func _add_sign(root: Node3D, sign_name: String, sign_position: Vector3, color: Color) -> void:
	_add_box(root, sign_name + "Post", Vector3(0.18, 1.5, 0.18), sign_position + Vector3(0.0, 0.75, 0.0), Color("624733"))
	_add_box(root, sign_name, Vector3(1.7, 0.75, 0.18), sign_position + Vector3(0.0, 1.45, 0.0), color)


static func _add_box(
	root: Node3D,
	node_name: String,
	size: Vector3,
	mesh_position: Vector3,
	color: Color,
	rotation: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = mesh_position
	instance.rotation_degrees = rotation
	instance.material_override = _material(color)
	root.add_child(instance)
	return instance


static func _add_cylinder(
	root: Node3D,
	node_name: String,
	radius: float,
	height: float,
	mesh_position: Vector3,
	color: Color,
	radial_segments: int = 12
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = radial_segments
	instance.mesh = mesh
	instance.position = mesh_position
	instance.material_override = _material(color)
	root.add_child(instance)
	return instance


static func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material

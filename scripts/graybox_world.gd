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
	_add_mara(root)

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

	return {"collectible": supplies, "camera": camera}


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
	var tree_positions := [
		Vector3(-15.0, 0.0, -9.0), Vector3(-11.5, 0.0, -12.0), Vector3(-8.0, 0.0, -9.5),
		Vector3(-4.8, 0.0, -12.5), Vector3(5.0, 0.0, -12.0), Vector3(8.5, 0.0, -9.0),
		Vector3(12.0, 0.0, -12.2), Vector3(15.0, 0.0, -9.5)
	]
	for index: int in tree_positions.size():
		_add_tree(root, "Tree%d" % index, tree_positions[index])


static func _add_tree(root: Node3D, tree_name: String, tree_position: Vector3) -> void:
	var trunk := _add_cylinder(root, tree_name + "Trunk", 0.35, 2.7, tree_position + Vector3(0.0, 1.35, 0.0), Color("76533c"))
	trunk.rotation_degrees.y = float(tree_name.hash() % 30)
	_add_cylinder(root, tree_name + "Crown", 1.35, 2.8, tree_position + Vector3(0.0, 3.4, 0.0), Color("376c46"), 6)


static func _add_landmark_signs(root: Node3D) -> void:
	_add_sign(root, "CottageSign", Vector3(-3.2, 0.0, 4.0), Color("e3bd68"))
	_add_sign(root, "ForestSign", Vector3(2.0, 0.0, -6.7), Color("77b879"))


static func _add_mara(root: Node3D) -> void:
	var body := MeshInstance3D.new()
	body.name = "Mara"
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.42
	body_mesh.height = 1.35
	body.mesh = body_mesh
	body.position = WorldStateModel.MARA_POSITION
	body.material_override = _material(Color("b45b72"))
	root.add_child(body)

	var name_label := Label3D.new()
	name_label.name = "MaraName"
	name_label.text = "Mara"
	name_label.position = WorldStateModel.MARA_POSITION + Vector3(0.0, 1.25, 0.0)
	name_label.font_size = 36
	name_label.outline_size = 8
	name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(name_label)


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

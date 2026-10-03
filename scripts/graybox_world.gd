class_name GrayboxWorld
extends RefCounted

const WorldStateModel = preload("res://scripts/world_state.gd")


static func build(root: Node3D) -> Dictionary:
	var atmosphere := _add_environment(root)
	_add_ground(root)
	_add_road(root)
	_add_cottage(root)
	var cottage_rest_marker := _add_cottage_rest_point(root)
	_add_forest_edge(root)
	_add_northern_region(root)
	_add_old_stone_ruins(root)
	_add_landmark_signs(root)
	var mara := _add_mara(root)
	var resource_nodes := _add_resources(root)
	var repair_nodes := _add_repair_markers(root)
	var repair_result_nodes := _add_repair_results(root)
	var welcome_lanterns := _add_welcome_lanterns(root)
	var creature := _add_creature(root)
	var rumor_marker := _add_rumor_marker(root)
	var ruin_guardian := _add_ruin_guardian(root)
	var waystones := _add_waystones(root)
	var livelihood := _add_livelihood_stations(root)
	var festival := _add_hearthlight_festival(root)

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
		"world_environment": atmosphere["environment"],
		"sun_light": atmosphere["sun_light"],
		"rain_particles": atmosphere["rain_particles"],
		"collectible": supplies,
		"camera": camera,
		"mara": mara,
		"resources": resource_nodes,
		"repairs": repair_nodes,
		"repair_results": repair_result_nodes,
		"cottage_rest_marker": cottage_rest_marker,
		"welcome_lantern_markers": welcome_lanterns["markers"],
		"welcome_lantern_lights": welcome_lanterns["lights"],
		"creature": creature,
		"rumor_marker": rumor_marker,
		"ruin_guardian": ruin_guardian,
		"waystone_marker": waystones["marker"],
		"home_waystone": waystones["home"],
		"ruin_waystone": waystones["ruin"],
		"waystone_glows": waystones["glows"],
		"garden_plants": livelihood["garden_plants"],
		"garden_markers": livelihood["garden_markers"],
		"cookfire_marker": livelihood["cookfire_marker"],
		"market_marker": livelihood["market_marker"],
		"produce_stall": livelihood["produce_stall"],
		"supply_marker": livelihood["supply_marker"],
		"hearthbloom_project": livelihood["hearthbloom_project"],
		"hearthbloom_marker": livelihood["hearthbloom_marker"],
		"hearthbloom_blooms": livelihood["hearthbloom_blooms"],
		"festival_arch": festival["arch"],
		"festival_decorations": festival["decorations"],
		"festival_checkpoints": festival["checkpoints"],
	}


static func _add_cottage_rest_point(root: Node3D) -> Node3D:
	var rest_position := WorldStateModel.COTTAGE_REST_POSITION
	_add_box(
		root,
		"CottageBedFrame",
		Vector3(2.3, 0.45, 1.15),
		rest_position + Vector3(0.0, -0.33, 0.0),
		Color("76513d")
	)
	_add_box(
		root,
		"CottageBedroll",
		Vector3(2.0, 0.32, 0.95),
		rest_position + Vector3(0.0, -0.03, 0.0),
		Color("7ca69a")
	)
	return _add_station_marker(root, "CottageRestMarker", rest_position, "REST AT HOME", Color("8ce0c5"))


static func _add_environment(root: Node3D) -> Dictionary:
	var environment := WorldEnvironment.new()
	environment.name = "WorldAtmosphere"
	var resource := Environment.new()
	resource.background_mode = Environment.BG_COLOR
	resource.background_color = Color("91c8dd")
	resource.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	resource.ambient_light_color = Color("fff4dc")
	resource.ambient_light_energy = 0.72
	environment.environment = resource
	root.add_child(environment)

	var light := DirectionalLight3D.new()
	light.name = "SunLight"
	light.rotation_degrees = Vector3(-55.0, -25.0, 0.0)
	light.shadow_enabled = true
	root.add_child(light)

	var rain := CPUParticles3D.new()
	rain.name = "GentleRain"
	rain.amount = 360
	rain.lifetime = 1.5
	rain.position = Vector3(0.0, 12.0, -17.0)
	rain.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	rain.emission_box_extents = Vector3(18.0, 1.0, 32.0)
	rain.direction = Vector3.DOWN
	rain.spread = 4.0
	rain.initial_velocity_min = 11.0
	rain.initial_velocity_max = 14.0
	rain.gravity = Vector3.ZERO
	var rain_drop := BoxMesh.new()
	rain_drop.size = Vector3(0.025, 0.55, 0.025)
	var rain_material := _material(Color(0.62, 0.82, 0.94, 0.58))
	rain_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rain_drop.material = rain_material
	rain.mesh = rain_drop
	rain.emitting = false
	root.add_child(rain)

	return {"environment": environment, "sun_light": light, "rain_particles": rain}


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


static func _add_northern_region(root: Node3D) -> void:
	_add_box(root, "NorthwoodGround", Vector3(36.0, 0.2, 34.0), Vector3(0.0, -0.1, -31.0), Color("426d48"))
	_add_box(root, "NorthernTrail", Vector3(4.2, 0.07, 36.0), Vector3(0.0, 0.045, -30.0), Color("786c5b"))
	var random := RandomNumberGenerator.new()
	random.seed = WorldStateModel.REGION_SEED
	var generated := 0
	var attempts := 0
	while generated < 22 and attempts < 100:
		attempts += 1
		var position := Vector3(random.randf_range(-15.5, 15.5), 0.0, random.randf_range(-46.0, -16.0))
		if absf(position.x) < 3.2 or position.distance_to(WorldStateModel.RUINS_POSITION) < 7.0:
			continue
		_add_tree(root, "NorthwoodTree%d" % generated, position)
		generated += 1
	for rock_index: int in 10:
		var side := -1.0 if rock_index % 2 == 0 else 1.0
		var rock_position := Vector3(side * random.randf_range(4.0, 14.0), 0.35, random.randf_range(-45.0, -18.0))
		_add_box(
			root,
			"NorthwoodRock%d" % rock_index,
			Vector3(random.randf_range(0.7, 1.8), random.randf_range(0.5, 1.2), random.randf_range(0.7, 1.6)),
			rock_position,
			Color("65706b"),
			Vector3(0.0, random.randf_range(0.0, 90.0), random.randf_range(-8.0, 8.0))
		)


static func _add_old_stone_ruins(root: Node3D) -> void:
	_add_box(root, "RuinsFloor", Vector3(13.0, 0.3, 9.0), Vector3(0.0, 0.05, -41.0), Color("66736e"))
	for x_position: float in [-5.0, 5.0]:
		_add_box(root, "RuinPillar", Vector3(1.4, 4.8, 1.4), Vector3(x_position, 2.4, -43.0), Color("87918a"))
	_add_box(root, "RuinLintel", Vector3(11.4, 1.2, 1.4), Vector3(0.0, 4.65, -43.0), Color("7a857f"), Vector3(0.0, 0.0, 3.0))
	_add_box(root, "BrokenRuinWallLeft", Vector3(4.2, 2.5, 0.8), Vector3(-4.3, 1.25, -45.0), Color("758079"), Vector3(0.0, 8.0, 0.0))
	_add_box(root, "BrokenRuinWallRight", Vector3(3.2, 1.7, 0.8), Vector3(4.8, 0.85, -45.0), Color("758079"), Vector3(0.0, -12.0, 0.0))
	var title := Label3D.new()
	title.name = "OldStoneRuinsLabel"
	title.text = "OLD STONE RUINS"
	title.position = Vector3(0.0, 5.8, -43.0)
	title.font_size = 56
	title.pixel_size = 0.01
	title.outline_size = 10
	title.modulate = Color("d8e4dc")
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(title)


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


static func _add_ruin_guardian(root: Node3D) -> MeshInstance3D:
	var guardian := MeshInstance3D.new()
	guardian.name = "RuinGuardian"
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.8
	mesh.height = 1.8
	guardian.mesh = mesh
	guardian.position = WorldStateModel.RUIN_GUARDIAN_SPAWN
	var material := _material(Color("9c6654"))
	material.emission_enabled = true
	material.emission = Color("56251f")
	material.emission_energy_multiplier = 1.4
	guardian.material_override = material
	guardian.visible = false
	root.add_child(guardian)
	return guardian


static func _add_waystones(root: Node3D) -> Dictionary:
	var home_data := _add_waystone(root, "HomeWaystone", WorldStateModel.HOME_WAYSTONE_POSITION)
	var ruin_data := _add_waystone(root, "RuinWaystone", WorldStateModel.RUIN_WAYSTONE_POSITION)
	var marker := Node3D.new()
	marker.name = "RestoreWaystoneMarker"
	marker.position = WorldStateModel.RUIN_WAYSTONE_POSITION
	root.add_child(marker)
	var disc := _add_cylinder(marker, "Disc", 0.9, 0.12, Vector3(0.0, -0.48, 0.0), Color("8bf0ff"), 20)
	var disc_material := disc.material_override as StandardMaterial3D
	disc_material.emission_enabled = true
	disc_material.emission = Color("35bfd6")
	disc_material.emission_energy_multiplier = 2.2
	var label := Label3D.new()
	label.name = "Label"
	label.text = "RESTORE WAYSTONE"
	label.position = Vector3(0.0, 2.7, 0.0)
	label.font_size = 46
	label.pixel_size = 0.008
	label.outline_size = 10
	label.modulate = Color("dffcff")
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	marker.add_child(label)
	marker.visible = false
	return {
		"home": home_data["root"],
		"ruin": ruin_data["root"],
		"marker": marker,
		"glows": {"home": home_data["glow"], "ruin": ruin_data["glow"]},
	}


static func _add_waystone(root: Node3D, node_name: String, position: Vector3) -> Dictionary:
	var waystone := Node3D.new()
	waystone.name = node_name
	waystone.position = position
	root.add_child(waystone)
	_add_cylinder(waystone, "Base", 0.9, 0.35, Vector3(0.0, -0.35, 0.0), Color("58645f"), 8)
	_add_box(waystone, "Stone", Vector3(0.8, 2.6, 0.65), Vector3(0.0, 0.9, 0.0), Color("71817a"), Vector3(0.0, 12.0, -3.0))
	var glow := _add_cylinder(waystone, "Glow", 0.22, 1.25, Vector3(0.0, 0.95, 0.35), Color("8bf0ff"), 12)
	var glow_material := glow.material_override as StandardMaterial3D
	glow_material.emission_enabled = true
	glow_material.emission = Color("35bfd6")
	glow_material.emission_energy_multiplier = 3.0
	glow.visible = false
	return {"root": waystone, "glow": glow}


static func _add_livelihood_stations(root: Node3D) -> Dictionary:
	var garden_plants := {}
	var garden_markers := {}
	for plot_id: String in WorldStateModel.GARDEN_PLOT_POSITIONS:
		var plot_position: Vector3 = WorldStateModel.GARDEN_PLOT_POSITIONS[plot_id]
		_add_box(root, "GardenSoil_%s" % plot_id, Vector3(2.2, 0.18, 1.5), plot_position - Vector3(0.0, 0.32, 0.0), Color("60452f"))
		var plant := _add_cylinder(root, "Moonroot_%s" % plot_id, 0.42, 0.7, plot_position, Color("9a74d6"), 7)
		var plant_material := plant.material_override as StandardMaterial3D
		plant_material.emission_enabled = true
		plant_material.emission = Color("51377d")
		garden_plants[plot_id] = plant
		var marker_text := "MOONROOT GARDEN" if plot_id == "moonroot_3" else ""
		var marker := _add_station_marker(root, "HarvestMarker_%s" % plot_id, plot_position, marker_text, Color("b997ef"))
		garden_markers[plot_id] = marker

	var cookfire := Node3D.new()
	cookfire.name = "CottageCookfire"
	cookfire.position = WorldStateModel.COOKFIRE_POSITION
	root.add_child(cookfire)
	_add_cylinder(cookfire, "FireRing", 0.75, 0.18, Vector3(0.0, -0.45, 0.0), Color("6c645e"), 12)
	var flame := _add_cylinder(cookfire, "Flame", 0.28, 0.75, Vector3(0.0, 0.05, 0.0), Color("ffb83d"), 8)
	var flame_material := flame.material_override as StandardMaterial3D
	flame_material.emission_enabled = true
	flame_material.emission = Color("ff7b25")
	flame_material.emission_energy_multiplier = 2.4
	var cookfire_marker := _add_station_marker(root, "CookfireMarker", WorldStateModel.COOKFIRE_POSITION, "COOK HEARTH STEW", Color("ffb83d"))

	_add_box(root, "MarketCrate", Vector3(1.8, 0.9, 1.3), WorldStateModel.MARKET_CRATE_POSITION, Color("8c603e"))
	var market_marker := _add_station_marker(root, "MarketDeliveryMarker", WorldStateModel.MARKET_CRATE_POSITION, "DELIVER STEW", Color("6ed9b5"))

	var produce_stall := Node3D.new()
	produce_stall.name = "ProduceStall"
	produce_stall.position = WorldStateModel.MARKET_CRATE_POSITION + Vector3(2.6, 0.0, 0.0)
	root.add_child(produce_stall)
	_add_box(produce_stall, "Counter", Vector3(3.4, 1.0, 1.5), Vector3(0.0, 0.25, 0.0), Color("96623c"))
	_add_box(produce_stall, "Canopy", Vector3(3.8, 0.25, 2.0), Vector3(0.0, 2.4, 0.0), Color("5fa66d"))
	for x_position: float in [-1.5, 1.5]:
		_add_box(produce_stall, "Post", Vector3(0.18, 2.4, 0.18), Vector3(x_position, 1.2, 0.0), Color("654632"))
	var stall_label := Label3D.new()
	stall_label.text = "NEIGHBORHOOD PRODUCE"
	stall_label.position = Vector3(0.0, 2.9, 0.0)
	stall_label.font_size = 42
	stall_label.pixel_size = 0.008
	stall_label.outline_size = 10
	stall_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	produce_stall.add_child(stall_label)
	produce_stall.visible = false

	var supply_basket := Node3D.new()
	supply_basket.name = "TrailSupplyBasket"
	supply_basket.position = WorldStateModel.SUPPLY_BASKET_POSITION
	root.add_child(supply_basket)
	_add_box(supply_basket, "Basket", Vector3(1.4, 0.7, 1.0), Vector3.ZERO, Color("9b6b43"))
	var supply_marker := _add_station_marker(
		supply_basket,
		"TrailSupplyMarker",
		Vector3.ZERO,
		"TRAIL SUPPLIES · 2 COIN",
		Color("f5cf73")
	)
	supply_marker.visible = true
	supply_basket.visible = false

	var hearthbloom_project := Node3D.new()
	hearthbloom_project.name = "HearthbloomProject"
	hearthbloom_project.position = WorldStateModel.HEARTHBLOOM_POSITION
	root.add_child(hearthbloom_project)
	_add_box(hearthbloom_project, "Planter", Vector3(2.6, 0.65, 1.2), Vector3(0.0, -0.12, 0.0), Color("8a5b3b"))
	_add_box(hearthbloom_project, "Soil", Vector3(2.3, 0.18, 0.95), Vector3(0.0, 0.26, 0.0), Color("493628"))
	var hearthbloom_marker := _add_station_marker(
		hearthbloom_project,
		"HearthbloomMarker",
		Vector3.ZERO,
		"HEARTHBLOOM PROJECT · CONTRIBUTE COIN",
		Color("f4b7dd")
	)
	var hearthbloom_blooms := Node3D.new()
	hearthbloom_blooms.name = "HearthbloomBlooms"
	hearthbloom_project.add_child(hearthbloom_blooms)
	for bloom_index: int in 5:
		var x_position := -0.9 + float(bloom_index) * 0.45
		_add_cylinder(
			hearthbloom_blooms,
			"Stem%d" % bloom_index,
			0.055,
			0.65 + 0.08 * float(bloom_index % 2),
			Vector3(x_position, 0.62, 0.0),
			Color("5e9d64"),
			8
		)
		var flower := _add_cylinder(
			hearthbloom_blooms,
			"Bloom%d" % bloom_index,
			0.22,
			0.16,
			Vector3(x_position, 1.0 + 0.08 * float(bloom_index % 2), 0.0),
			Color("e99acb") if bloom_index % 2 == 0 else Color("ffd782"),
			8
		)
		var flower_material := flower.material_override as StandardMaterial3D
		flower_material.emission_enabled = true
		flower_material.emission = flower_material.albedo_color * 0.55
	hearthbloom_project.visible = false
	hearthbloom_marker.visible = false
	hearthbloom_blooms.visible = false

	return {
		"garden_plants": garden_plants,
		"garden_markers": garden_markers,
		"cookfire_marker": cookfire_marker,
		"market_marker": market_marker,
		"produce_stall": produce_stall,
		"supply_marker": supply_basket,
		"hearthbloom_project": hearthbloom_project,
		"hearthbloom_marker": hearthbloom_marker,
		"hearthbloom_blooms": hearthbloom_blooms,
	}


static func _add_hearthlight_festival(root: Node3D) -> Dictionary:
	var arch := Node3D.new()
	arch.name = "HearthlightFestivalArch"
	arch.position = WorldStateModel.FESTIVAL_ARCH_POSITION
	root.add_child(arch)
	for x_position: float in [-1.5, 1.5]:
		_add_box(arch, "ArchPost", Vector3(0.3, 3.2, 0.3), Vector3(x_position, 1.1, 0.0), Color("6d4934"))
	_add_box(arch, "ArchBeam", Vector3(3.3, 0.35, 0.35), Vector3(0.0, 2.65, 0.0), Color("6d4934"))
	var arch_glow := _add_cylinder(arch, "Hearthlight", 0.35, 0.7, Vector3(0.0, 2.55, 0.0), Color("ffd45e"), 12)
	var arch_material := arch_glow.material_override as StandardMaterial3D
	arch_material.emission_enabled = true
	arch_material.emission = Color("f5a623")
	arch_material.emission_energy_multiplier = 2.5
	var arch_label := Label3D.new()
	arch_label.text = "HEARTHLIGHT CIRCUIT"
	arch_label.position = Vector3(0.0, 3.25, 0.0)
	arch_label.font_size = 46
	arch_label.pixel_size = 0.008
	arch_label.outline_size = 10
	arch_label.modulate = Color("fff0b8")
	arch_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	arch.add_child(arch_label)
	arch.visible = false

	var checkpoints := {}
	for checkpoint_index: int in WorldStateModel.FESTIVAL_CHECKPOINT_ORDER.size():
		var checkpoint_id: String = WorldStateModel.FESTIVAL_CHECKPOINT_ORDER[checkpoint_index]
		var checkpoint := _add_station_marker(
			root,
			"FestivalCheckpoint_%s" % checkpoint_id,
			WorldStateModel.FESTIVAL_CHECKPOINT_POSITIONS[checkpoint_id],
			"CIRCUIT %d" % (checkpoint_index + 1),
			Color("ffd45e")
		)
		checkpoints[checkpoint_id] = checkpoint

	var decorations := Node3D.new()
	decorations.name = "HearthlightFestivalDecorations"
	root.add_child(decorations)
	for x_position: float in [-6.0, -3.0, 0.0, 3.0, 6.0]:
		var color := Color("ef6f6c") if int(x_position) % 2 == 0 else Color("6ed9b5")
		_add_box(decorations, "FestivalBanner", Vector3(1.2, 0.7, 0.12), Vector3(x_position, 3.0, 2.0), color)
	for lantern_position: Vector3 in [Vector3(-6.0, 1.8, 2.0), Vector3(0.0, 1.8, 2.0), Vector3(6.0, 1.8, 2.0)]:
		var lantern := _add_cylinder(decorations, "FestivalLantern", 0.22, 0.5, lantern_position, Color("ffd45e"), 10)
		var lantern_material := lantern.material_override as StandardMaterial3D
		lantern_material.emission_enabled = true
		lantern_material.emission = Color("f5a623")
		lantern_material.emission_energy_multiplier = 2.0
	decorations.visible = false
	return {"arch": arch, "decorations": decorations, "checkpoints": checkpoints}


static func _add_station_marker(root: Node3D, node_name: String, position: Vector3, text: String, color: Color) -> Node3D:
	var marker := Node3D.new()
	marker.name = node_name
	marker.position = position
	root.add_child(marker)
	var disc := _add_cylinder(marker, "Disc", 0.7, 0.1, Vector3(0.0, -0.48, 0.0), color, 20)
	var disc_material := disc.material_override as StandardMaterial3D
	disc_material.emission_enabled = true
	disc_material.emission = color
	disc_material.emission_energy_multiplier = 1.8
	if not text.is_empty():
		var label := Label3D.new()
		label.name = "Label"
		label.text = text
		label.position = Vector3(0.0, 1.2, 0.0)
		label.font_size = 42
		label.pixel_size = 0.008
		label.outline_size = 10
		label.modulate = Color("f4efff")
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		marker.add_child(label)
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

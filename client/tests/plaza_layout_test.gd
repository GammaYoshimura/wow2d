extends SceneTree

var _failures := 0

func _initialize() -> void:
	var layout_path := ProjectSettings.globalize_path("res://").path_join("../content/plaza_v1.json")
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(layout_path))
	var plaza: Node2D = load("res://world/plaza.tscn").instantiate()
	var ground: TileMapLayer = plaza.get_node("Ground")
	var obstacles: TileMapLayer = plaza.get_node("Obstacles")
	var size := _cell(layout.size)
	var origin := Vector2(_cell(layout.origin))
	var pitch := float(layout.tile_size)
	var solid_cells := {}
	for point: Array in layout.solid_cells:
		solid_cells[_cell(point)] = true

	_check(ground.get_used_rect() == Rect2i(Vector2i.ZERO, size), "Map bounds")
	_check(ground.get_used_cells().size() == size.x * size.y, "Full ground coverage")
	_check(obstacles.get_used_cells().size() == solid_cells.size(), "Solid cell count")
	var corners := [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]
	for cell: Vector2i in obstacles.get_used_cells():
		_check(solid_cells.has(cell), "Unexpected solid tile %s" % str(cell))
		_check(obstacles.map_to_local(cell) == origin + (Vector2(cell) + Vector2(0.5, 0.5)) * pitch,
			"Collision cell center %s" % str(cell))
		var tile := obstacles.get_cell_tile_data(cell)
		_check(tile.get_collision_polygons_count(0) == 1, "Missing tile collider %s" % str(cell))
		if tile.get_collision_polygons_count(0) == 1:
			var polygon := tile.get_collision_polygon_points(0, 0)
			_check(polygon.size() == 4, "Tile collider must be rectangular")
			for corner: Vector2 in corners:
				_check(polygon.has(corner * pitch / 2.0), "Collider corner %s" % str(cell))

	for name: String in layout.landmarks:
		var cell := _cell(layout.landmarks[name])
		var marker: Marker2D = plaza.get_node("Landmarks").get_node(name)
		_check(marker.position == origin + (Vector2(cell) + Vector2(0.5, 0.5)) * pitch, name)
		_check(solid_cells.has(cell) == (name == "well"), "Landmark traversal %s" % name)
	for i in range(layout.spawn_points.size()):
		var cell := _cell(layout.spawn_points[i])
		var marker: Marker2D = plaza.get_node("Spawns/Spawn%d" % (i + 1))
		_check(ground.local_to_map(marker.position) == cell and not solid_cells.has(cell), marker.name)

	if _failures == 0:
		print("plaza_v1: %d×%d, %d solid tiles, %d landmarks, %d spawns" %
			[size.x, size.y, solid_cells.size(), layout.landmarks.size(), layout.spawn_points.size()])
	plaza.free()
	quit(1 if _failures else 0)

func _cell(pair: Array) -> Vector2i:
	return Vector2i(int(pair[0]), int(pair[1]))

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures += 1
		push_error(message)

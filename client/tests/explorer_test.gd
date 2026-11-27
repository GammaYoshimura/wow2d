extends SceneTree

var _failures := 0

func _initialize() -> void:
	call_deferred("_exercise")

func _exercise() -> void:
	var plaza: Node2D = load("res://world/plaza.tscn").instantiate()
	root.add_child(plaza)
	var explorer: CharacterBody2D = plaza.get_node("Explorer")
	var camera: Camera2D = explorer.get_node("Camera2D")
	await physics_frame
	var start := Vector2(220, 220)
	explorer.position = start
	await _walk(["walk_right"], 30)
	var cardinal := explorer.position.distance_to(start)
	explorer.position = start
	await _walk(["walk_right", "walk_down"], 30)
	var diagonal := explorer.position.distance_to(start)
	_check(cardinal > 60.0, "Cardinal movement")
	_check(absf(cardinal - diagonal) / cardinal < 0.02, "Diagonal speed differs by 2% or more (%.2f vs %.2f)" % [cardinal, diagonal])

	explorer.position = Vector2(140, 320)
	await _walk(["walk_left"], 90)
	_check(absf(explorer.position.x - 74.0) < 0.2, "West fence blocks the player")
	var stop := explorer.position
	await _walk([], 8)
	_check(explorer.position.distance_to(stop) < 0.01, "Released input stops the player")

	camera.force_update_scroll()
	_check(camera.get_screen_center_position().x >= 319.9, "West camera edge")
	explorer.position = Vector2(880, 400)
	camera.force_update_scroll()
	_check(camera.get_screen_center_position().x <= 704.1, "East camera edge")

	if _failures == 0:
		print("Walk: %.2f cardinal, %.2f diagonal, fence x=%.2f, camera limited" %
			[cardinal, diagonal, stop.x])
	quit(1 if _failures else 0)

func _walk(actions: Array, ticks: int) -> void:
	for action: String in actions:
		Input.action_press(action)
	for _tick in range(ticks):
		await physics_frame
	for action: String in actions:
		Input.action_release(action)

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures += 1
		push_error(message)

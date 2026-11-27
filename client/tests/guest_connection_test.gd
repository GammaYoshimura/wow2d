extends SceneTree

func _initialize() -> void:
	call_deferred("_exercise")

func _exercise() -> void:
	var endpoint := OS.get_environment("WOW2D_GAME_URL")
	if endpoint.is_empty():
		push_error("Set WOW2D_GAME_URL to a fresh local server.")
		quit(1)
		return

	var scene := load("res://world/plaza.tscn") as PackedScene
	var first := scene.instantiate()
	var second := scene.instantiate()
	root.add_child(first)
	root.add_child(second)
	var a: PanelContainer = first.get_node("Interface/GuestConnection")
	var b: PanelContainer = second.get_node("Interface/GuestConnection")

	a.get_node("Margin/Rows/Enter").emit_signal("pressed")
	if not await _wait_until(func() -> bool: return not a.entity_id.is_empty()):
		push_error("First Godot client did not receive a welcome.")
		quit(1)
		return
	b.get_node("Margin/Rows/Enter").emit_signal("pressed")
	if not await _wait_until(func() -> bool: return not b.entity_id.is_empty()):
		push_error("Second Godot client did not receive a welcome.")
		quit(1)
		return

	var a_spawn: Vector2 = first.get_node("Explorer").position
	var b_spawn: Vector2 = second.get_node("Explorer").position
	if a.entity_id == b.entity_id or a_spawn != Vector2(464, 592) or b_spawn != Vector2(528, 592):
		push_error("Guest IDs or authoritative spawns do not match the plaza.")
		quit(1)
		return

	var explorer: CharacterBody2D = first.get_node("Explorer")
	second.get_node("Explorer").set_physics_process(false)
	Input.action_press("walk_left")
	var reached_fence := await _wait_until(func() -> bool: return is_equal_approx(explorer.position.x, 74.0), 4500)
	Input.action_release("walk_left")
	if not reached_fence or explorer.position.y != 592.0:
		push_error("Confirmed player position did not reach the west fence.")
		quit(1)
		return

	Input.action_press("walk_right")
	var moved_away := await _wait_until(func() -> bool: return explorer.position.x >= 115.0)
	var last_move: int = a.last_confirmed_sequence
	Input.action_release("walk_right")
	if not moved_away or not await _wait_until(func() -> bool: return a.last_confirmed_sequence > last_move):
		push_error("The server did not acknowledge the release.")
		quit(1)
		return
	await create_timer(0.25).timeout
	var stopped := explorer.position
	await create_timer(0.25).timeout
	if explorer.position != stopped or second.get_node("Explorer").position != b_spawn:
		push_error("The first guest drifted after input release or moved a different guest.")
		quit(1)
		return
	print("Server confirmed fence x=74, movement away, then stop at %s" % stopped)

	var error_client: PanelContainer = load("res://world/guest_connection.tscn").instantiate()
	root.add_child(error_client)
	error_client.connect_guest(endpoint, "old_map")
	var status: Label = error_client.get_node("Margin/Rows/Status")
	if not await _wait_until(func() -> bool: return "versión del mapa" in status.text):
		push_error("Incompatible map error was not shown in Godot.")
		quit(1)
		return
	print("Godot guests %s %s and %s %s; incompatible map shown in UI" %
		[a.entity_id, a_spawn, b.entity_id, b_spawn])
	quit(0)

func _wait_until(condition: Callable, timeout_ms := 3000) -> bool:
	var deadline := Time.get_ticks_msec() + timeout_ms
	while Time.get_ticks_msec() < deadline:
		if condition.call():
			return true
		await process_frame
	return false

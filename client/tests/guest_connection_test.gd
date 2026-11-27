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

func _wait_until(condition: Callable) -> bool:
	var deadline := Time.get_ticks_msec() + 3000
	while Time.get_ticks_msec() < deadline:
		if condition.call():
			return true
		await process_frame
	return false

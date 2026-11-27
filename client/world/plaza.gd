extends Node2D

@onready var _ground: TileMapLayer = $Ground
@onready var _explorer: CharacterBody2D = $Explorer

func _ready() -> void:
	var tile_bounds := _ground.get_used_rect()
	var tile_size := Vector2(_ground.tile_set.tile_size)
	var origin := _ground.map_to_local(tile_bounds.position) - tile_size / 2.0
	_explorer.position = $Spawns/Spawn1.position
	_explorer.configure_bounds(Rect2(origin, Vector2(tile_bounds.size) * tile_size))
	$Interface/GuestConnection.entered.connect(_enter_as_guest)
	$Interface/GuestConnection.left.connect(func() -> void: _explorer.set_physics_process(true))

func _enter_as_guest(spawn: Vector2) -> void:
	_explorer.set_physics_process(false)
	_explorer.position = spawn

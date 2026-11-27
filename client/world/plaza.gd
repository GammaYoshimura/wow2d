extends Node2D

@onready var _ground: TileMapLayer = $Ground
@onready var _explorer: CharacterBody2D = $Explorer
@onready var _guest: PanelContainer = $Interface/GuestConnection

func _ready() -> void:
	var tile_bounds := _ground.get_used_rect()
	var tile_size := Vector2(_ground.tile_set.tile_size)
	var origin := _ground.map_to_local(tile_bounds.position) - tile_size / 2.0
	_explorer.position = $Spawns/Spawn1.position
	_explorer.configure_bounds(Rect2(origin, Vector2(tile_bounds.size) * tile_size))
	_guest.entered.connect(_enter_as_guest)
	_guest.left.connect(func() -> void: _explorer.authoritative = false)
	_guest.position_confirmed.connect(_explorer.apply_confirmed_position)
	_explorer.move_requested.connect(_guest.submit_movement)

func _enter_as_guest(spawn: Vector2) -> void:
	_explorer.authoritative = true
	_explorer.position = spawn

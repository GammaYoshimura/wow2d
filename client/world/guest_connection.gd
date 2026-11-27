extends PanelContainer

signal entered(spawn: Vector2)
signal left
signal position_confirmed(confirmed: Vector2)

const PROTOCOL := 2
const MAP_REVISION := "plaza_v1"
const DEFAULT_URL := "ws://127.0.0.1:8080/game"
const HANDSHAKE_TIMEOUT_MS := 6000
const INPUT_REFRESH_MS := 100

@onready var _status: Label = $Margin/Rows/Status
@onready var _button: Button = $Margin/Rows/Enter

var entity_id := ""
var last_confirmed_tick := -1
var last_confirmed_sequence := 0
var _peer: WebSocketPeer
var _requested_revision := MAP_REVISION
var _hello_sent := false
var _deadline := 0
var _next_sequence := 1
var _last_direction := Vector2.ZERO
var _next_input_refresh := 0

func _ready() -> void:
	_button.pressed.connect(_toggle_connection)

func _toggle_connection() -> void:
	if _peer != null:
		_end_connection("Exploración local · WASD / flechas")
		return
	connect_guest(_game_endpoint(), MAP_REVISION)

func _game_endpoint() -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--server="):
			return argument.trim_prefix("--server=")
	var endpoint := OS.get_environment("WOW2D_GAME_URL")
	if not endpoint.is_empty():
		return endpoint
	return String(ProjectSettings.get_setting("wow2d/network/game_url", DEFAULT_URL))

func connect_guest(endpoint: String, map_revision: String) -> void:
	if _peer != null:
		return
	_peer = WebSocketPeer.new()
	_requested_revision = map_revision
	if _peer.connect_to_url(endpoint) != OK:
		_end_connection("No se pudo abrir la conexión.")
		return
	_deadline = Time.get_ticks_msec() + HANDSHAKE_TIMEOUT_MS
	_status.text = "Conectando al Vado…"
	_button.text = "Cancelar"

func submit_movement(direction: Vector2) -> void:
	if entity_id.is_empty() or _peer.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	var now := Time.get_ticks_msec()
	if direction == _last_direction and (direction == Vector2.ZERO or now < _next_input_refresh):
		return
	var message := {
		"type": "move",
		"sequence": _next_sequence,
		"direction": {"x": direction.x, "y": direction.y},
	}
	if _peer.send_text(JSON.stringify(message)) != OK:
		_end_connection("Se perdió la conexión con el Vado.")
		return
	_next_sequence += 1
	_last_direction = direction
	_next_input_refresh = now + INPUT_REFRESH_MS

func _process(_delta: float) -> void:
	if _peer == null:
		return
	_peer.poll()
	var state := _peer.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN and not _hello_sent:
		var message := {"type": "hello", "protocol": PROTOCOL, "map_revision": _requested_revision}
		if _peer.send_text(JSON.stringify(message)) != OK:
			_end_connection("No se pudo solicitar la entrada.")
			return
		_hello_sent = true
	while _peer != null and _peer.get_available_packet_count() > 0:
		_read_message(_peer.get_packet().get_string_from_utf8())
	if _peer == null:
		return
	if state == WebSocketPeer.STATE_CLOSED and _peer.get_close_code() == 1008 and entity_id.is_empty():
		_show_join_error(_peer.get_close_reason())
		return
	if state == WebSocketPeer.STATE_CLOSED or (entity_id.is_empty() and Time.get_ticks_msec() >= _deadline):
		_end_connection("Se perdió la conexión con el Vado." if not entity_id.is_empty()
			else "No se pudo conectar al Vado.")

func _read_message(payload: String) -> void:
	var decoded: Variant = JSON.parse_string(payload)
	if not decoded is Dictionary:
		_end_connection("Respuesta de entrada inválida.")
		return
	var message: Dictionary = decoded
	match message.get("type"):
		"error":
			_show_join_error(str(message.get("code", "")))
		"welcome":
			var spawn: Variant = message.get("spawn")
			var id: Variant = message.get("entity_id")
			if not _valid_position(spawn) or not id is String or id.is_empty():
				_end_connection("Respuesta de entrada inválida.")
				return
			entity_id = id
			last_confirmed_tick = int(message.get("tick", -1))
			_status.text = "En el Vado · %s" % entity_id
			_button.text = "Salir"
			entered.emit(Vector2(float(spawn["x"]), float(spawn["y"])))
		"position":
			var tick := int(message.get("tick", -1))
			var point: Variant = message.get("position")
			if not entity_id.is_empty() and tick > last_confirmed_tick and _valid_position(point):
				last_confirmed_tick = tick
				last_confirmed_sequence = int(message.get("sequence", 0))
				position_confirmed.emit(Vector2(float(point["x"]), float(point["y"])))

func _valid_position(point: Variant) -> bool:
	return point is Dictionary and point.get("x") is float and point.get("y") is float

func _show_join_error(code: String) -> void:
	match code:
		"map_mismatch":
			_end_connection("La versión del mapa no coincide con la del servidor.")
		"protocol_mismatch":
			_end_connection("El servidor necesita otra versión del cliente.")
		_:
			_end_connection("El servidor no pudo admitir al invitado.")

func _end_connection(message: String) -> void:
	if _peer != null and _peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		_peer.close()
	_peer = null
	_hello_sent = false
	entity_id = ""
	last_confirmed_tick = -1
	last_confirmed_sequence = 0
	_next_sequence = 1
	_last_direction = Vector2.ZERO
	_next_input_refresh = 0
	_status.text = message
	_button.text = "Entrar como invitado"
	left.emit()

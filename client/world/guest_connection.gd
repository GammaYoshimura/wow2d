extends PanelContainer

signal entered(spawn: Vector2)
signal left

const PROTOCOL := 1
const MAP_REVISION := "plaza_v1"
const DEFAULT_URL := "ws://127.0.0.1:8080/game"
const HANDSHAKE_TIMEOUT_MS := 6000

@onready var _status: Label = $Margin/Rows/Status
@onready var _button: Button = $Margin/Rows/Enter

var entity_id := ""
var _peer: WebSocketPeer
var _requested_revision := MAP_REVISION
var _hello_sent := false
var _deadline := 0

func _ready() -> void:
	_button.pressed.connect(_toggle_connection)

func _toggle_connection() -> void:
	if _peer != null:
		_end_connection("Exploración local · WASD / flechas")
		return
	var endpoint := OS.get_environment("WOW2D_GAME_URL")
	connect_guest(DEFAULT_URL if endpoint.is_empty() else endpoint, MAP_REVISION)

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
			match message.get("code"):
				"map_mismatch":
					_end_connection("La versión del mapa no coincide con la del servidor.")
				"protocol_mismatch":
					_end_connection("El servidor necesita otra versión del cliente.")
				_:
					_end_connection("El servidor no pudo admitir al invitado.")
		"welcome":
			var spawn: Variant = message.get("spawn")
			var id: Variant = message.get("entity_id")
			if not spawn is Dictionary or not id is String or id.is_empty() or not spawn.has_all(["x", "y"]):
				_end_connection("Respuesta de entrada inválida.")
				return
			entity_id = id
			_status.text = "En el Vado · %s" % entity_id
			_button.text = "Salir"
			entered.emit(Vector2(float(spawn["x"]), float(spawn["y"])))

func _end_connection(message: String) -> void:
	if _peer != null and _peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		_peer.close()
	_peer = null
	_hello_sent = false
	entity_id = ""
	_status.text = message
	_button.text = "Entrar como invitado"
	left.emit()

extends Node
## เล่นเสียงให้ปุ่มทุกปุ่มในเกมอัตโนมัติ
## - เมาส์เลื่อนผ่านปุ่ม  -> Select.mp3
## - กดปุ่ม              -> Click.mp3

const SELECT_SOUND := preload("res://asset/Sound/Select.mp3")
const CLICK_SOUND := preload("res://asset/Sound/Click.mp3")

@export var select_volume_db: float = 0.0
@export var click_volume_db: float = 0.0

var _select_player: AudioStreamPlayer
var _click_player: AudioStreamPlayer

func _ready() -> void:
	# ต้องเป็น Always ไม่งั้นตอนเกมถูก pause เสียงในเมนู pause จะไม่ดัง
	process_mode = Node.PROCESS_MODE_ALWAYS

	_select_player = AudioStreamPlayer.new()
	_select_player.stream = SELECT_SOUND
	_select_player.volume_db = select_volume_db
	add_child(_select_player)

	_click_player = AudioStreamPlayer.new()
	_click_player.stream = CLICK_SOUND
	_click_player.volume_db = click_volume_db
	add_child(_click_player)

	# ทุกครั้งที่มี node ใหม่เข้ามาในฉาก ถ้าเป็นปุ่มให้ต่อเสียง
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		node.mouse_entered.connect(_on_button_hover.bind(node))
		node.pressed.connect(_on_button_pressed)

func _on_button_hover(button: BaseButton) -> void:
	if button.disabled:
		return
	_select_player.play()

func _on_button_pressed() -> void:
	_click_player.play()

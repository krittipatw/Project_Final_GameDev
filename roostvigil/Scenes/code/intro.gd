extends Control
## Intro ข้อความล้วน: ขึ้นทีละบรรทัด fade เข้า-ออก แล้วเข้าเกม กดปุ่มข้ามได้

const NEXT_SCENE := "res://Scenes/level.tscn"   # <- แก้เป็น scene เกมของคุณ
const FADE_TIME := 1.0
const HOLD_TIME := 2.5
const GAP_TIME := 0.5

@export_multiline var lines: Array[String] = [
	"Do not gaze into what should remain unseen",
	"Not all calls for help come from the living.",
	"Remain forever in the light, far from the reach of darkness..",
]

@onready var label: Label = $Label

var going := false
var tween: Tween


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	label.modulate.a = 0.0
	_play()


func _play() -> void:
	for line in lines:
		label.text = line
		tween = create_tween()
		tween.tween_property(label, "modulate:a", 1.0, FADE_TIME)
		tween.tween_interval(HOLD_TIME)
		tween.tween_property(label, "modulate:a", 0.0, FADE_TIME)
		await tween.finished
		if going:
			return
		await get_tree().create_timer(GAP_TIME).timeout
		if going:
			return
	_go_next()


func _unhandled_input(event: InputEvent) -> void:
	var skip: bool = event.is_action_pressed("jump") \
		or event.is_action_pressed("ui_cancel") \
		or (event is InputEventMouseButton and event.pressed)
	if skip:
		_go_next()


func _go_next() -> void:
	if going:
		return
	going = true
	if tween:
		tween.kill()
	get_tree().change_scene_to_file(NEXT_SCENE)

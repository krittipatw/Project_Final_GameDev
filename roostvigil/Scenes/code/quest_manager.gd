extends Node

signal quest_started(id: String)
signal quest_completed(id: String)
signal all_completed

const QUESTS := [
	{"id": "find_watch_tower", "text": "Find a flashlight"},
	{"id": "read_notebook", "text": "Read Notebook"},
	{"id": "find_pass_code", "text": "Find passcode"},
]

const START_DELAY := 1.5            # รอกี่วินาทีหลังเข้า level ก่อนเควสเริ่มขึ้น
const FADE_IN := 2.0                # fade ขึ้นนานกี่วินาที
const FADE_OUT := 0.4

const COL_TITLE := Color(0.75, 0.12, 0.12)
const COL_TEXT := Color(0.9, 0.85, 0.75)
const COL_DONE := Color(0.2, 1.0, 0.3)

var index := 0
var started := false                # true = อยู่ใน level และแสดงเควสแล้ว
var finished := false
var busy := false
var done := {}

var box: Control
var title_label: Label
var quest_label: Label

func _ready() -> void:
	_build_ui()
	box.visible = false             # ซ่อนไว้ก่อน (intro / เมนู ไม่เห็นเควส)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	margin.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 36)
	layer.add_child(margin)

	box = VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(box)

	title_label = Label.new()
	title_label.text = "QUEST"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", COL_TITLE)
	title_label.add_theme_color_override("font_outline_color", Color.BLACK)
	title_label.add_theme_constant_override("outline_size", 6)
	box.add_child(title_label)

	quest_label = Label.new()
	quest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	quest_label.add_theme_font_size_override("font_size", 28)
	quest_label.add_theme_color_override("font_color", COL_TEXT)
	quest_label.add_theme_color_override("font_outline_color", Color.BLACK)
	quest_label.add_theme_constant_override("outline_size", 8)
	box.add_child(quest_label)

# ---------- Public API ----------
# เรียกตอนเริ่ม level (จาก Player._ready) : เควสจะ fade ขึ้น
func start(delay: float = START_DELAY) -> void:
	if started:
		return
	started = true
	await get_tree().create_timer(delay).timeout
	if not started:                 # โดน reset ระหว่างรอ
		return
	_show_current()

# เรียกตอนออกจาก level / restart : ซ่อนและล้างสถานะ
func reset() -> void:
	started = false
	finished = false
	busy = false
	index = 0
	done.clear()
	box.visible = false

func complete(id: String) -> void:
	if finished or done.has(id):
		return
	done[id] = true
	if started and not busy and QUESTS[index]["id"] == id:
		_advance()

func current_id() -> String:
	return "" if finished else QUESTS[index]["id"]

# ---------- Internal ----------
func _show_current(fade_time: float = FADE_IN) -> void:
	if finished or index >= QUESTS.size():
		box.visible = false
		return
	box.visible = true
	quest_label.text = "[ ] " + QUESTS[index]["text"]
	quest_label.add_theme_color_override("font_color", COL_TEXT)
	box.modulate.a = 0.0
	create_tween().tween_property(box, "modulate:a", 1.0, fade_time)
	quest_started.emit(QUESTS[index]["id"])

	# เควสนี้เคยทำเสร็จไปก่อนแล้ว ให้ข้ามต่อ
	if done.has(QUESTS[index]["id"]):
		_advance()

func _advance() -> void:
	busy = true
	var id: String = QUESTS[index]["id"]
	quest_label.text = "[x] " + QUESTS[index]["text"]
	quest_label.add_theme_color_override("font_color", COL_DONE)
	quest_completed.emit(id)

	await get_tree().create_timer(1.6).timeout
	if not started:
		return
	var tween := create_tween()
	tween.tween_property(box, "modulate:a", 0.0, FADE_OUT)
	await tween.finished
	if not started:
		return

	index += 1
	busy = false
	if index >= QUESTS.size():
		finished = true
		box.visible = false
		all_completed.emit()
		return
	_show_current(0.6)              # เควสถัดไป fade เร็วกว่าครั้งแรกเล็กน้อย

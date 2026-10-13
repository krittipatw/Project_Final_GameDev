extends Control

# เลือกซีนด่านใน Inspector (ใช้กับปุ่ม Play Again)
@export_file("*.tscn") var level_scene: String = ""

const FADE_IN_TIME := 2.5
const TITLE_FONT := 96
const SUB_FONT := 32
const BTN_FONT := 36

const COL_BG := Color(0, 0, 0)
const COL_TITLE := Color(0.2, 1.0, 0.3)
const COL_TEXT := Color(0.85, 0.8, 0.7)
const COL_BORDER := Color(0.45, 0.08, 0.08)
const COL_BTN := Color(0.11, 0.09, 0.08)
const COL_BTN_HOVER := Color(0.25, 0.08, 0.08)
const COL_BTN_PRESSED := Color(0.4, 0.1, 0.1)

func _ready() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()

	# Fade in ทั้งหน้าจอ
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, FADE_IN_TIME)

func _box(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(4)
	return sb

func _make_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(320, 80)
	btn.add_theme_font_size_override("font_size", BTN_FONT)
	btn.add_theme_stylebox_override("normal", _box(COL_BTN, COL_BORDER.darkened(0.3)))
	btn.add_theme_stylebox_override("hover", _box(COL_BTN_HOVER, COL_BORDER))
	btn.add_theme_stylebox_override("pressed", _box(COL_BTN_PRESSED, COL_BORDER))
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn.add_theme_color_override("font_color", COL_TEXT)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	return btn

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = COL_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 28)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(vbox)

	var title := Label.new()
	title.text = "YOU ESCAPED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", TITLE_FONT)
	title.add_theme_color_override("font_color", COL_TITLE)
	vbox.add_child(title)

	var sub := Label.new()
	sub.text = "The nightmare is over... for now."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", SUB_FONT)
	sub.add_theme_color_override("font_color", COL_TEXT)
	vbox.add_child(sub)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(spacer)

	var again := _make_button("Play Again")
	again.pressed.connect(_on_play_again)
	vbox.add_child(again)

	var quit := _make_button("Quit")
	quit.pressed.connect(_on_quit)
	vbox.add_child(quit)

func _on_play_again() -> void:
	QuestManager.reset()
	if level_scene != "":
		get_tree().change_scene_to_file(level_scene)
	else:
		push_warning("level_scene ยังไม่ได้ตั้งค่าใน Inspector ของ WinScreen")

func _on_quit() -> void:
	get_tree().quit()

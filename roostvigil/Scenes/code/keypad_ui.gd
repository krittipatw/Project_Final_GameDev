
extends Control

const CORRECT_CODE := "0867"
const WIN_SCENE := "res://Scenes/win_screen.tscn"
const SUCCESS_DELAY := 1.8

# ขนาด UI ลดลงประมาณ 20%
const BUTTON_SIZE := Vector2(120, 88)
const BUTTON_FONT := 38
const DISPLAY_FONT := 58

# ธีมสี
const COL_PANEL_BG := Color(0.05, 0.04, 0.04, 0.96)
const COL_BORDER := Color(0.45, 0.08, 0.08)
const COL_SCREEN_BG := Color(0.02, 0.03, 0.02)
const COL_TEXT := Color(0.85, 0.8, 0.7)
const COL_BTN := Color(0.11, 0.09, 0.08)
const COL_BTN_HOVER := Color(0.25, 0.08, 0.08)
const COL_BTN_PRESSED := Color(0.4, 0.1, 0.1)
const COL_OK := Color(0.2, 1.0, 0.3)
const COL_BAD := Color(0.95, 0.15, 0.15)

var display: Label
var screen_box: StyleBoxFlat
var grid: GridContainer
var entered := ""
var locked := false


func _ready() -> void:
	add_to_group("blocking_ui")
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	for child in get_children():
		child.queue_free()

	_build_ui()
	_refresh()


# ---------- Style helpers ----------

func _box(
	bg: Color,
	border: Color,
	border_w: int = 2,
	radius: int = 4
) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	return sb


func _style_button(btn: Button, base: Color = COL_BTN) -> void:
	btn.add_theme_stylebox_override(
		"normal",
		_box(base, COL_BORDER.darkened(0.3))
	)
	btn.add_theme_stylebox_override(
		"hover",
		_box(COL_BTN_HOVER, COL_BORDER)
	)
	btn.add_theme_stylebox_override(
		"pressed",
		_box(COL_BTN_PRESSED, COL_BAD)
	)
	btn.add_theme_stylebox_override(
		"disabled",
		_box(base.darkened(0.4), COL_BORDER.darkened(0.6))
	)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	btn.add_theme_color_override("font_color", COL_TEXT)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override(
		"font_disabled_color",
		COL_TEXT.darkened(0.6)
	)


# ---------- Build UI ----------

func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.8)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override(
		"panel",
		_box(COL_PANEL_BG, COL_BORDER, 4, 8)
	)
	center.add_child(panel)

	var margin := MarginContainer.new()

	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override(
			"margin_" + side,
			29
		)

	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)

	# ---------- Header / Exit button ----------

	var header := HBoxContainer.new()
	vbox.add_child(header)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)

	var exit_btn := Button.new()
	exit_btn.text = "X"
	exit_btn.custom_minimum_size = Vector2(51, 51)
	exit_btn.add_theme_font_size_override("font_size", 26)

	_style_button(exit_btn, Color(0.18, 0.05, 0.05))
	exit_btn.pressed.connect(close)

	header.add_child(exit_btn)

	# ---------- Code display ----------

	var screen := PanelContainer.new()

	screen_box = _box(
		COL_SCREEN_BG,
		COL_BORDER,
		3,
		4
	)

	screen.add_theme_stylebox_override("panel", screen_box)
	vbox.add_child(screen)

	display = Label.new()
	display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	display.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	display.add_theme_font_size_override(
		"font_size",
		DISPLAY_FONT
	)
	display.add_theme_color_override("font_color", COL_TEXT)
	display.custom_minimum_size = Vector2(0, 88)

	screen.add_child(display)

	# ---------- Number buttons ----------

	grid = GridContainer.new()
	grid.columns = 3

	grid.add_theme_constant_override("h_separation", 11)
	grid.add_theme_constant_override("v_separation", 11)

	vbox.add_child(grid)

	for label in [
		"1", "2", "3",
		"4", "5", "6",
		"7", "8", "9",
		"Clear", "0", "Enter"
	]:
		var btn := Button.new()
		btn.text = label
		btn.custom_minimum_size = BUTTON_SIZE

		btn.add_theme_font_size_override(
			"font_size",
			BUTTON_FONT if label.is_valid_int() else 29
		)

		_style_button(btn)
		btn.pressed.connect(_on_button.bind(label))

		grid.add_child(btn)


# ---------- Open / Close ----------

func open() -> void:
	entered = ""
	locked = false

	_set_buttons_disabled(false)

	display.modulate.a = 1.0
	modulate.a = 1.0

	_set_display_state(COL_TEXT, COL_BORDER)
	_refresh()

	visible = true
	modulate.a = 0.0

	create_tween().tween_property(
		self,
		"modulate:a",
		1.0,
		0.2
	)

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func close() -> void:
	if locked:
		return

	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

	elif event is InputEventKey and event.pressed and not event.echo:
		var c := char(event.unicode)

		if c.is_valid_int():
			_on_button(c)

		elif event.keycode == KEY_BACKSPACE and not locked:
			if entered.length() > 0:
				entered = entered.substr(
					0,
					entered.length() - 1
				)
			_refresh()

		elif (
			event.keycode == KEY_ENTER
			or event.keycode == KEY_KP_ENTER
		):
			_submit()

		get_viewport().set_input_as_handled()


# ---------- Input logic ----------

func _on_button(label: String) -> void:
	if locked:
		return

	if label == "Clear":
		entered = ""

	elif label == "Enter":
		_submit()
		return

	elif (
		label.is_valid_int()
		and entered.length() < CORRECT_CODE.length()
	):
		entered += label

		if entered.length() == CORRECT_CODE.length():
			_submit()
			return

	_refresh()


func _submit() -> void:
	if locked:
		return

	locked = true
	_set_buttons_disabled(true)

	if entered == CORRECT_CODE:
		_win()
	else:
		await _wrong()


# ---------- Wrong code ----------

func _wrong() -> void:
	display.text = "WRONG"
	_set_display_state(COL_BAD, COL_BAD)

	# กะพริบ 3 ครั้ง
	var tween := create_tween()

	for i in 3:
		tween.tween_property(
			display,
			"modulate:a",
			0.15,
			0.08
		)
		tween.tween_property(
			display,
			"modulate:a",
			1.0,
			0.08
		)

	await tween.finished

	await get_tree().create_timer(0.25).timeout

	entered = ""
	display.modulate.a = 1.0

	_set_display_state(COL_TEXT, COL_BORDER)
	_set_buttons_disabled(false)

	locked = false
	_refresh()


# ---------- Correct code ----------

func _win() -> void:
	QuestManager.complete("find_pass_code")

	display.text = "SUCCESS"
	_set_display_state(COL_OK, COL_OK)

	await get_tree().create_timer(SUCCESS_DELAY).timeout

	if WIN_SCENE != "":
		get_tree().change_scene_to_file(WIN_SCENE)
	else:
		get_tree().paused = true


# ---------- Helpers ----------

func _set_display_state(
	text_col: Color,
	border_col: Color
) -> void:
	display.add_theme_color_override(
		"font_color",
		text_col
	)
	screen_box.border_color = border_col


func _set_buttons_disabled(value: bool) -> void:
	for btn in grid.get_children():
		if btn is Button:
			btn.disabled = value


func _refresh() -> void:
	if display == null:
		return

	display.text = (
		"*".repeat(entered.length())
		if entered != ""
		else "----"
	)

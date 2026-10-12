extends Control

# ---------- เปลี่ยนฉาก ----------
@export_file("*.tscn") var game_scene: String = "res://Scenes/intro.tscn"

# ---------- สไลด์พื้นหลัง ----------
@export var hold_time: float = 2.5
@export var fade_time: float = 1.0

@onready var layers: Array[TextureRect] = [$BG1, $BG2, $BG3, $BG4]

# ---------- ปุ่ม ----------
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var credit_button: Button = $VBoxContainer/CreditButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# พื้นหลัง: เริ่มต้นโชว์แค่ภาพแรก
	for i in layers.size():
		layers[i].modulate.a = 1.0 if i == 0 else 0.0

	# ปุ่ม
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	credit_button.pressed.connect(_on_credit_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	start_button.grab_focus()

	_cycle()

# ---------- พื้นหลังสไลด์ ----------
func _cycle() -> void:
	var current := 0
	while is_inside_tree():
		await get_tree().create_timer(hold_time).timeout
		if not is_inside_tree():
			return
		var next := (current + 1) % layers.size()

		# ยกภาพถัดไปขึ้นบนสุดของกลุ่ม BG (ยังอยู่ใต้ Label และปุ่ม)
		move_child(layers[next], layers.size() - 1)

		var tw := create_tween()
		tw.tween_property(layers[next], "modulate:a", 1.0, fade_time)
		await tw.finished
		if not is_inside_tree():
			return

		layers[current].modulate.a = 0.0
		current = next

# ---------- ปุ่ม ----------
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(game_scene)

func _on_options_pressed() -> void:
	print("Options: ยังไม่ได้ทำ")  # ใส่ฉาก Options ภายหลัง

func _on_credit_pressed() -> void:
	print("Credit: ยังไม่ได้ทำ")   # ใส่ฉาก Credit ภายหลัง

func _on_quit_pressed() -> void:
	get_tree().quit()

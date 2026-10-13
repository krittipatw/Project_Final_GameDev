extends CanvasLayer

@export_file("*.tscn") var main_menu_scene: String = "res://Scenes/tscn/main_menu.tscn"
@export_file("*.tscn") var options_scene: String = "res://Scenes/tscn/options_menu.tscn"


@onready var root: Control = $Root
@onready var resume_button: Button = $Root/VBoxContainer/ResumeButton
@onready var restart_button: Button = $Root/VBoxContainer/RestartButton
@onready var options_button: Button = $Root/VBoxContainer/OptionsButton
@onready var exit_button: Button = $Root/VBoxContainer/ExitButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root.visible = false
	resume_button.pressed.connect(resume)
	restart_button.pressed.connect(_on_restart_pressed)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	# ไม่เปิดเมนูถ้าสมุดบันทึกเปิดอยู่
	var notebook := get_tree().get_first_node_in_group("notebook_ui")
	if notebook != null and notebook.visible:
		return
	get_viewport().set_input_as_handled()
	if root.visible:
		resume()
	else:
		pause()

func pause() -> void:
	root.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	resume_button.grab_focus()

func resume() -> void:
	root.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_restart_pressed() -> void:
	QuestManager.reset()
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_options_pressed() -> void:
	if not ResourceLoader.exists(options_scene):
		push_warning("ไม่พบฉาก Options ที่พาธ: " + options_scene)
		return
	var packed: PackedScene = load(options_scene)
	var options := packed.instantiate()
	add_child(options)  # PauseMenu เป็น CanvasLayer จึงวาดทับทั้งหน้า
	options.closed.connect(options_button.grab_focus)

func _on_exit_pressed() -> void:
	QuestManager.reset()
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_scene)

extends Control

signal closed

@onready var slider: HSlider = $PanelContainer/VBoxContainer/MasterSlider
@onready var back_button: Button = $BackButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # ใช้ได้ตอนเกม pause

	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = Settings.master_volume
	slider.value_changed.connect(Settings.set_master_volume)

	back_button.pressed.connect(_close)
	slider.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	Settings.save()
	closed.emit()
	queue_free()

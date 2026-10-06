extends Control

## หน้าเมนูก่อนเริ่มเกม (Roostvigil)
## ตอนนี้ปุ่ม Start ยังไม่เปลี่ยนฉาก เปลี่ยน GAME_READY เป็น true เมื่อเกมพร้อม

const GAME_READY := false

@export_file("*.tscn") var game_scene: String = "res://Scenes/level.tscn"

@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	start_button.grab_focus()


func _on_start_pressed() -> void:
	if GAME_READY:
		get_tree().change_scene_to_file(game_scene)
	else:
		print("Start pressed (เกมยังไม่พร้อม)")


func _on_quit_pressed() -> void:
	get_tree().quit()

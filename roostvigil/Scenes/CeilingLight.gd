extends Node3D

# ชื่อกลุ่มต้องตรงกับ LightSwitch ที่ควบคุมโคมนี้
@export var light_group: StringName = &"room1"

@onready var light: Light3D = $Light

func _ready() -> void:
	add_to_group(light_group)
	set_on(false)  # เริ่มเกมด้วยไฟดับ

func set_on(value: bool) -> void:
	print("CeilingLight set_on: ", value)
	light.visible = value

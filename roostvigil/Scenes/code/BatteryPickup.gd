extends StaticBody3D

@export var item_name: String = "Battery"
@export var charge_amount: float = 25.0	# เพิ่มกี่ % ต่อก้อน (ปรับรายก้อนได้ใน Inspector)

func get_prompt() -> String:
	return item_name

func interact(player = null) -> void:
	if player and player.has_method("try_add_battery"):
		# เก็บสำเร็จเท่านั้น แบตก้อนนี้ถึงจะหายไปจากแมพ
		if player.try_add_battery(charge_amount):
			queue_free()

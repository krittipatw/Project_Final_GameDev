extends StaticBody3D

@export var item_name: String = "Flashlight"

func get_prompt() -> String:
	return item_name

func interact(player = null) -> void:
	if player and player.has_method("pick_up_flashlight"):
		player.pick_up_flashlight()
		queue_free()  # ลบไฟฉายออกจากแมพ

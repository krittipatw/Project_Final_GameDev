extends StaticBody3D

@export var keypad_path: NodePath

func get_prompt() -> String:
	return "Phone"          # Player ต่อเป็น "[E] Phone" ให้เอง

func interact(player) -> void:
	var keypad = get_node_or_null(keypad_path)
	if keypad:
		keypad.open()

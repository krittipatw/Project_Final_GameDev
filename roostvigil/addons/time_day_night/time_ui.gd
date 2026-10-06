@tool
class_name TimeUI
extends Control

const TIME_SYSTEM_UI_NODE = preload("uid://drotx7icj3xw5")

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		call_deferred("_create_required_nodes")
		
func _create_required_nodes() -> void:
	var scene_root := get_tree().edited_scene_root

	if scene_root == null:
		return


	var time_system = get_node_or_null("Time_system_UI")

	if time_system == null:
		time_system = TIME_SYSTEM_UI_NODE.instantiate()
		time_system.name = "Time_system_UI"

		add_child(time_system)
		time_system.owner = scene_root

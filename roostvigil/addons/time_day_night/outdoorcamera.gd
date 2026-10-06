@tool
class_name OutdoorCam
extends Camera2D
const SHADOWS = preload("uid://dqypivfdtjr6c")
const LIGHT_CONTROL = preload("uid://b5xiie10kqdre")

var shadows
var canvas_modulate


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		call_deferred("_create_required_nodes")


func _create_required_nodes() -> void:
	var scene_root := get_tree().edited_scene_root

	if scene_root == null:
		return


	# Light Control
	canvas_modulate = get_node_or_null("LightControl")

	if canvas_modulate == null:
		canvas_modulate = LIGHT_CONTROL.instantiate()
		canvas_modulate.name = "LightControl"

		add_child(canvas_modulate)
		canvas_modulate.owner = scene_root


	# Shadows
	shadows = get_node_or_null("Shadows")

	if shadows == null:
		shadows = SHADOWS.instantiate()
		shadows.name = "Shadows"

		add_child(shadows)
		shadows.owner = scene_root

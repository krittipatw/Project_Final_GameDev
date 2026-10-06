@tool
extends Polygon2D

@export var margin: float = 100.0

var last_zoom := Vector2.ZERO


func _process(_delta: float) -> void:
	var camera := get_parent() as Camera2D
	
	if camera == null:
		return
	
	if camera.zoom != last_zoom:
		last_zoom = camera.zoom
		update_polygon()


func update_polygon() -> void:
	var camera := get_parent() as Camera2D
	
	if camera == null:
		return
	
	var viewport_size := get_viewport_rect().size
	var visible_size := viewport_size / camera.zoom
	
	var half_size := visible_size / 2.0
	half_size += Vector2(margin, margin)
	
	polygon = PackedVector2Array([
		Vector2(-half_size.x, -half_size.y),
		Vector2( half_size.x, -half_size.y),
		Vector2( half_size.x,  half_size.y),
		Vector2(-half_size.x,  half_size.y)
	])

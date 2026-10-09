extends Label

func _ready():
	add_theme_color_override("font_color", Color.YELLOW)
	add_theme_color_override("font_outline_color", Color.BLACK)
	add_theme_constant_override("outline_size", 4)
	add_theme_font_size_override("font_size", 20)

func _process(_delta: float) -> void:
	text = "FPS: %d" % Engine.get_frames_per_second()

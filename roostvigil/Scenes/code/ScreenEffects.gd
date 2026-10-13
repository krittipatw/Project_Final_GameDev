extends CanvasLayer

@onready var static_rect: ColorRect = $StaticRect
@onready var flash_rect: ColorRect = $FlashRect

func _ready() -> void:
	add_to_group("screen_effects")
	set_static(0.0)
	flash_rect.visible = true
	flash_rect.modulate.a = 0.0

# 0 = ไม่มี, 1 = เต็มจอ (ศัตรูทุกตัวเรียกใช้ได้)
func set_static(amount: float) -> void:
	amount = clampf(amount, 0.0, 1.0)
	static_rect.visible = amount > 0.0
	var mat := static_rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("intensity", amount)

# จอวาบขาวแล้วค่อยๆ จางลง (peak = ความขาวสูงสุด 0 ถึง 1)
func flash(duration: float = 0.5, peak: float = 1.0) -> void:
	flash_rect.modulate.a = peak
	var tween := create_tween()
	tween.tween_property(flash_rect, "modulate:a", 0.0, duration)

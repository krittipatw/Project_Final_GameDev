extends CanvasLayer

@onready var static_rect: ColorRect = $StaticRect

func _ready() -> void:
	add_to_group("screen_effects")
	set_static(0.0)

# 0 = ไม่มี, 1 = เต็มจอ (ศัตรูทุกตัวเรียกใช้ฟังก์ชันนี้ได้)
func set_static(amount: float) -> void:
	amount = clampf(amount, 0.0, 1.0)
	static_rect.visible = amount > 0.0
	var mat := static_rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("intensity", amount)

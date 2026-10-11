extends StaticBody3D

# ชื่อกลุ่มของโคมไฟที่สวิตช์นี้ควบคุม (ต้องตรงกับ CeilingLight)
@export var light_group: StringName = &"room1"
# เว้นว่างไว้ = ใช้อนิเมชันแรกที่เจอ (ตอนนี้คือ "Take 01")
@export var animation_name: String = ""

var is_on := false
var anim: AnimationPlayer

func _ready() -> void:
	anim = find_child("AnimationPlayer", true, false) as AnimationPlayer
	if anim == null:
		push_warning("LightSwitch: ไม่พบ AnimationPlayer ในโมเดลสวิตช์")
		return
	if animation_name == "":
		for n in anim.get_animation_list():
			if n != "RESET":
				animation_name = n
				break
	print("LightSwitch animations: ", anim.get_animation_list(), " -> using: ", animation_name)

func get_prompt() -> String:
	return "Turn off light" if is_on else "Turn on light"

func interact(_player = null) -> void:
	# ถ้าอนิเมชันยังเล่นไม่จบ ไม่รับคำสั่งซ้ำ
	if anim and anim.is_playing():
		return

	is_on = not is_on
	_play_switch_animation()

	var count := get_tree().get_nodes_in_group(light_group).size()
	print("LightSwitch: is_on = ", is_on, " | lights in group '", light_group, "' = ", count)
	get_tree().call_group(light_group, "set_on", is_on)

func _play_switch_animation() -> void:
	if anim == null or animation_name == "":
		return
	if is_on:
		anim.play(animation_name)
	else:
		anim.play_backwards(animation_name)  # เล่นย้อนกลับตอนปิดไฟ

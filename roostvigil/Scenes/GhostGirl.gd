extends Node3D

# ---------- เดินวน ----------
const WALK_SPEED = 1.2				# ความเร็วเดิน (เมตร/วินาที)
const TURN_SPEED = 4.0				# ความเร็วหันตัว
const MODEL_YAW_OFFSET_DEG = 180.0	# ทิศหน้าของโมเดล
const ANIM_SPEED_SCALE = 1.0		# ความเร็วอนิเมชัน (ปรับถ้าเท้าลื่น)
const WAIT_MIN = 1.0				# หยุดพักที่แต่ละจุดอย่างน้อยกี่วินาที
const WAIT_MAX = 3.0				# (ตั้ง 0 ทั้งคู่ = เดินไม่หยุดพัก)
const MAX_HOP_DISTANCE = 8.0		# เลือกจุดถัดไปที่ห่างไม่เกินเท่านี้ (กันเดินตัดผ่านบ่อน้ำ)
const ARRIVE_DISTANCE = 0.2

# ---------- การถูกมอง ----------
const GAZE_MAX_DISTANCE = 20.0		# ไกลกว่านี้ไม่นับว่ามอง
const GAZE_MAX_ANGLE_DEG = 40.0		# ต้องอยู่ใกล้กลางจอไม่เกินกี่องศา
const GAZE_TARGET_OFFSET = Vector3(0.0, 1.0, 0.0)	# จุดที่ใช้ตรวจ (กลางลำตัว นับจากเท้า)
const GAZE_BLOCK_MASK = 1			# collision layer ที่บังสายตาได้
const GAZE_TIME_TO_SCARE = 3.0		# จ้องครบกี่วินาทีถึงจะ jumpscare
const GAZE_DECAY_MULT = 1.0			# หันหนีแล้ว static ลดลงเร็วแค่ไหน (1 = เท่ากับตอนขึ้น)
const START_GRACE = 8.0				# ช่วงเว้นตอนเริ่มเกม ผียังไม่ตอบสนองต่อสายตา (วินาที)

# ---------- ขยับเข้ามาตอนถูกมอง ----------
const CREEP_TIMES = [1.0, 2.0]		# จ้องครบกี่วินาที ผีถึงจะขยับเข้ามา 1 ก้าว
const CREEP_STEP = 1.0				# ก้าวละกี่เมตร
const CREEP_MIN_DISTANCE = 3.0		# ไม่เข้าใกล้กว่านี้ (จนกว่าจะ jumpscare)

# ---------- Jumpscare ----------
const SANITY_DAMAGE = 20.0			# ลด Sanity เท่าไหร่
const SCARE_START_DISTANCE = 2.8	# ผีโผล่ห่างหน้าผู้เล่นกี่เมตร ก่อนพุ่งเข้าใส่
const SCARE_DISTANCE = 1.0			# ระยะที่ผีหยุดหน้าผู้เล่น (เมตร)
const SCARE_LIFT = 0.6				# ยกผีลอยขึ้นจากพื้นกี่เมตร (กล้องจะเงยมองเห็นใบหน้า)
const SCARE_LUNGE_TIME = 0.18		# เวลาที่พุ่งเข้าใส่ (วินาที)
const SCARE_HOLD = 1.2				# ค้างให้เห็นหน้าผีกี่วินาที ก่อนวาร์ปหนี (ผู้เล่นขยับไม่ได้)
const FACE_HEIGHT = 1.4				# ความสูงใบหน้าผี นับจากเท้า (กล้องจะเล็งตรงนี้)
const SCARE_LIGHT_BOOST = 4.0		# คูณความสว่างของแสงส่องหน้าตอน jumpscare
const SCARE_YAW_FIX_DEG = -15.0		# หมุนผีเพิ่มตอน jumpscare ให้หันหน้าตรง (กด K ทดสอบทีละ 45°)
const SCARE_POSE_FRACTION = 0.0		# ท่าค้างตอน jumpscare เป็นกี่ส่วนของท่าเดิน (0.0 ถึง 0.99)
const SCARE_TILT_DEG = 0.0			# เอนตัวผีไปด้านหลัง (ห่างจากผู้เล่น) ให้หน้าเงยขึ้น (ลอง 20 หรือ -20 ถ้าก้มหนักกว่าเดิม)
const POST_SCARE_GRACE = 10.0		# หลังวาร์ป ผีไม่ตอบสนองต่อสายตากี่วินาที
const TELEPORT_MIN_DISTANCE = 6.0	# วาร์ปไปจุดที่ห่างผู้เล่นอย่างน้อยกี่เมตร

# ปุ่มทดสอบ (J = jumpscare ทันที, K = เปลี่ยนทิศหน้า, L = เปลี่ยนท่าค้าง) ปิดได้เมื่อได้ค่าที่ชอบแล้ว
const DEBUG_KEYS = true

# ---------- แสงเรือง ----------
const GLOW_COLOR = Color(0.2, 1.0, 0.8)	# ฟ้าอมเขียว
const GLOW_LIGHT_ENERGY = 0.4			# ความสว่างของแสงที่ส่องพื้นรอบตัว
const GLOW_LIGHT_RANGE = 4.0			# ระยะแสง (เมตร)
const GLOW_LIGHT_POS = Vector3(0.0, 1.0, 0.0)	# ตำแหน่งแสงตอนปกติ (กลางลำตัว)
const GLOW_PULSE_SPEED = 2.0			# ความเร็วที่แสงหายใจเข้าออก
const GLOW_SHADER_CODE = """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_back;

uniform vec4 glow_color : source_color = vec4(0.2, 1.0, 0.8, 1.0);
uniform float intensity = 1.0;
uniform float rim_power = 2.0;
uniform float base_glow = 0.12;

void fragment() {
	float fres = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), rim_power);
	ALBEDO = glow_color.rgb;
	ALPHA = clamp((base_glow + fres) * intensity, 0.0, 1.0);
}
"""

# เว้นว่างไว้ = ใช้อนิเมชันแรกที่เจอในโมเดล
@export var walk_animation: String = ""

var waypoints: Array[Node3D] = []
var target: Node3D = null
var wait_timer := 0.0
var anim: AnimationPlayer
var anim_playing := false

var player = null					# ไม่ระบุชนิด เพราะต้องเรียกฟังก์ชันของ player.gd
var screen_fx = null
var frozen := false					# true = กำลังถูกมอง แข็งทื่อ
var scaring := false				# true = กำลังอยู่ในจังหวะ jumpscare
var stare_time := 0.0
var static_value := 0.0
var grace_timer := START_GRACE
var creep_index := 0

var glow_light: OmniLight3D = null
var glow_material: ShaderMaterial = null
var glow_time := 0.0
var glow_boost := 1.0				# ตัวคูณความสว่างของแสงส่อง (เพิ่มชั่วคราวตอน jumpscare)

var scare_yaw_fix_deg := SCARE_YAW_FIX_DEG
var scare_pose_fraction := SCARE_POSE_FRACTION

func _ready() -> void:
	add_to_group("ghost_girl")
	_find_waypoints()
	_setup_animation()
	_setup_glow()
	_pick_next_waypoint()

# ---------- Waypoints ----------
func _find_waypoints() -> void:
	var root := get_tree().current_scene.get_node_or_null("GhostWaypoints")
	if root == null:
		push_warning("GhostGirl: ไม่พบ node GhostWaypoints ใน level")
		return
	for child in root.get_children():
		if child is Node3D:
			waypoints.append(child as Node3D)
	if waypoints.is_empty():
		push_warning("GhostGirl: GhostWaypoints ไม่มี Marker3D ข้างใน")

func _pick_next_waypoint() -> void:
	if waypoints.is_empty():
		return

	# เลือกเฉพาะจุดที่ไม่ไกลเกินไป (กันเดินตัดผ่านกลางบ่อน้ำ)
	var candidates: Array[Node3D] = []
	for p in waypoints:
		if p == target:
			continue
		if p.global_position.distance_to(global_position) <= MAX_HOP_DISTANCE:
			candidates.append(p)

	if candidates.is_empty():
		for p in waypoints:
			if p != target:
				candidates.append(p)
	if candidates.is_empty():
		candidates.append(waypoints[0])

	target = candidates.pick_random()

# ---------- Animation ----------
func _setup_animation() -> void:
	anim = find_child("AnimationPlayer", true, false) as AnimationPlayer
	if anim == null:
		push_warning("GhostGirl: ไม่พบ AnimationPlayer ในโมเดล")
		return

	if walk_animation == "":
		for n in anim.get_animation_list():
			if n != "RESET":
				walk_animation = n
				break
	print("GhostGirl animations: ", anim.get_animation_list(), " -> using: ", walk_animation)

	if walk_animation != "" and anim.has_animation(walk_animation):
		# ให้วนซ้ำเสมอ ไม่ต้องไปตั้งใน Import
		anim.get_animation(walk_animation).loop_mode = Animation.LOOP_LINEAR
	anim.speed_scale = ANIM_SPEED_SCALE
	_apply_anim_state()

# เล่นท่าเดินเฉพาะตอนเดินจริง (หยุดพักหรือถูกมอง = ค้างท่าไว้)
func _apply_anim_state() -> void:
	if anim == null or walk_animation == "":
		return
	var should_play := (not frozen) and wait_timer <= 0.0
	if should_play and not anim_playing:
		anim.play(walk_animation)
		anim_playing = true
	elif not should_play and anim_playing:
		anim.pause()
		anim_playing = false

# ค้างท่าเดินที่เฟรมที่กำหนด ให้ท่าตอน jumpscare เหมือนเดิมทุกครั้ง
func _set_scare_pose() -> void:
	if anim == null or walk_animation == "" or not anim.has_animation(walk_animation):
		return
	var length := anim.get_animation(walk_animation).length
	anim.play(walk_animation)
	anim.pause()
	anim.seek(length * scare_pose_fraction, true)
	anim_playing = false

# ---------- แสงเรือง ----------
func _setup_glow() -> void:
	# 1) แสงสีฟ้าอมเขียวส่องพื้นและต้นไม้รอบตัว (สร้างเป็นลูกของผี)
	glow_light = OmniLight3D.new()
	glow_light.name = "GlowLight"
	glow_light.light_color = GLOW_COLOR
	glow_light.light_energy = GLOW_LIGHT_ENERGY
	glow_light.omni_range = GLOW_LIGHT_RANGE
	glow_light.shadow_enabled = false
	glow_light.position = GLOW_LIGHT_POS
	glow_light.add_to_group("ghost_light")	# ระบบ Sanity จะไม่นับแสงนี้เป็นที่สว่าง
	add_child(glow_light)

	# 2) ขอบเรืองแสงบนผิวโมเดล (material overlay ทับตัวเดิมทุกชิ้น)
	var shader := Shader.new()
	shader.code = GLOW_SHADER_CODE
	glow_material = ShaderMaterial.new()
	glow_material.shader = shader
	glow_material.set_shader_parameter("glow_color", GLOW_COLOR)
	for mesh in find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_overlay = glow_material

func _update_glow(delta: float) -> void:
	glow_time += delta
	var pulse := 1.0 + 0.2 * sin(glow_time * GLOW_PULSE_SPEED)
	if glow_light:
		glow_light.light_energy = GLOW_LIGHT_ENERGY * pulse * glow_boost
	if glow_material:
		glow_material.set_shader_parameter("intensity", pulse)	# ไม่คูณ boost เพื่อไม่ให้ทับพื้นผิวโมเดล

# ---------- ทุกเฟรม ----------
func _process(delta: float) -> void:
	_update_glow(delta)

	# ระหว่าง jumpscare ให้ _jumpscare() คุมทิศทางเอง ไม่ให้ _face_player มาทับ
	if scaring:
		return

	if frozen:
		_face_player(delta)
	else:
		_patrol(delta)
	_apply_anim_state()

func _patrol(delta: float) -> void:
	if waypoints.is_empty() or target == null:
		return

	# กำลังหยุดพักที่จุด
	if wait_timer > 0.0:
		wait_timer -= delta
		if wait_timer <= 0.0:
			_pick_next_waypoint()
		return

	var to_target := target.global_position - global_position

	# ถึงจุดแล้ว
	if to_target.length() <= ARRIVE_DISTANCE:
		wait_timer = randf_range(WAIT_MIN, WAIT_MAX)
		if wait_timer <= 0.0:
			_pick_next_waypoint()
		return

	_turn_toward(Vector3(to_target.x, 0.0, to_target.z), delta, 1.0)
	global_position = global_position.move_toward(target.global_position, WALK_SPEED * delta)

func _face_player(delta: float) -> void:
	if player == null:
		return
	var to_player: Vector3 = player.global_position - global_position
	_turn_toward(Vector3(to_player.x, 0.0, to_player.z), delta, 2.0)

func _yaw_for(flat_dir: Vector3) -> float:
	return atan2(-flat_dir.x, -flat_dir.z) + deg_to_rad(MODEL_YAW_OFFSET_DEG)

func _turn_toward(flat_dir: Vector3, delta: float, speed_mult: float) -> void:
	if flat_dir.length() < 0.01:
		return
	rotation.y = lerp_angle(rotation.y, _yaw_for(flat_dir), clamp(TURN_SPEED * speed_mult * delta, 0.0, 1.0))

# ---------- ตรวจการถูกมอง (ต้องอยู่ใน physics เพราะใช้ raycast) ----------
func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return  # ยังไม่เจอ player (ตรวจว่ามี add_to_group("player") ใน player.gd แล้ว)

	# กำลัง jumpscare อยู่ ให้ลำดับเหตุการณ์ใน _jumpscare() จัดการเอง
	if scaring:
		return

	# ผู้เล่นตายแล้ว: เลิกตอบสนอง
	if player.get("is_dead"):
		frozen = false
		_set_static(0.0)
		return

	# กำลังอ่านสมุด: ผีหยุดนิ่ง ไม่นับเวลาจ้อง และ static ค่อยๆ จาง
	if _notebook_open():
		frozen = true
		static_value = move_toward(static_value, 0.0, delta * 4.0)
		_set_static(static_value)
		return

	if grace_timer > 0.0:
		grace_timer -= delta

	var seen := grace_timer <= 0.0 and _can_player_see_me()
	frozen = seen

	if seen:
		stare_time = minf(stare_time + delta, GAZE_TIME_TO_SCARE)
		# ขยับเข้ามาทีละก้าวตามเวลาที่จ้อง
		if creep_index < CREEP_TIMES.size() and stare_time >= CREEP_TIMES[creep_index]:
			_creep_closer()
			creep_index += 1
	else:
		stare_time = maxf(stare_time - delta * GAZE_DECAY_MULT, 0.0)
		if stare_time <= 0.0:
			creep_index = 0

	# จ้องครบเวลา -> jumpscare
	if stare_time >= GAZE_TIME_TO_SCARE:
		_jumpscare()
		return

	# static ค่อยๆ แรงขึ้นตามเวลาที่จ้อง (เริ่มเร็ว แล้วค่อยๆ เต็ม)
	var target_static := sqrt(stare_time / GAZE_TIME_TO_SCARE)
	static_value = move_toward(static_value, target_static, delta * 4.0)
	_set_static(static_value)

func _can_player_see_me() -> bool:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return false

	var point := global_position + GAZE_TARGET_OFFSET
	var cam_pos := cam.global_position

	# 1) ไม่ไกลเกินไป
	if cam_pos.distance_to(point) > GAZE_MAX_DISTANCE:
		return false

	# 2) อยู่ในกรอบภาพ และอยู่ใกล้กลางจอพอ (ถือว่า "มอง")
	if not cam.is_position_in_frustum(point):
		return false
	var cam_forward := -cam.global_transform.basis.z
	var dir := (point - cam_pos).normalized()
	if dir.dot(cam_forward) < cos(deg_to_rad(GAZE_MAX_ANGLE_DEG)):
		return false

	# 3) ไม่มีอะไรบังสายตา
	var query := PhysicsRayQueryParameters3D.create(cam_pos, point, GAZE_BLOCK_MASK)
	query.exclude = [player.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty()

func _notebook_open() -> bool:
	var ui = get_tree().get_first_node_in_group("notebook_ui")
	return ui != null and ui.visible

func _set_static(value: float) -> void:
	if screen_fx == null:
		screen_fx = get_tree().get_first_node_in_group("screen_effects")
	if screen_fx:
		screen_fx.set_static(value)

# ---------- ขยับเข้ามา ----------
func _creep_closer() -> void:
	var to_player: Vector3 = player.global_position - global_position
	var flat := Vector3(to_player.x, 0.0, to_player.z)
	var dist := flat.length()
	var step := minf(CREEP_STEP, dist - CREEP_MIN_DISTANCE)
	if step <= 0.0:
		return
	global_position += flat.normalized() * step
	static_value = 1.0  # static วูบเต็มจอ บังตอนผีขยับ แล้วค่อยๆ ลดลง

# ---------- Jumpscare ----------
# ตั้งทิศหน้า + เอนตัวไปด้านหลัง (เอนในพิกัดโลก เทียบกับทิศที่มองผู้เล่น ไม่ขึ้นกับทิศหน้าของโมเดล)
func _set_scare_orientation() -> void:
	var to_player: Vector3 = player.global_position - global_position
	var flat := Vector3(to_player.x, 0.0, to_player.z)
	if flat.length() < 0.01:
		return
	# รีเซ็ตเป็นตั้งตรงก่อน แล้วหมุนทิศหน้า
	rotation = Vector3(0.0, _yaw_for(flat) + deg_to_rad(scare_yaw_fix_deg), 0.0)
	# เอนส่วนบนของตัวให้ห่างจากผู้เล่น (หน้าจะเงยขึ้นมาหากล้อง)
	var away := -flat.normalized()
	var axis := Vector3.UP.cross(away)
	if axis.length() > 0.001 and not is_zero_approx(SCARE_TILT_DEG):
		global_transform.basis = Basis(axis.normalized(), deg_to_rad(SCARE_TILT_DEG)) * global_transform.basis

func _jumpscare() -> void:
	scaring = true
	frozen = true
	_set_static(0.0)

	# ผีโผล่ตรงหน้าผู้เล่น (ไกลหน่อย) แล้วพุ่งเข้าใส่ ขณะพุ่งลอยสูงขึ้นจากพื้น
	var forward: Vector3 = -player.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var ground_y := global_position.y
	var start_pos: Vector3 = player.global_position + forward * SCARE_START_DISTANCE
	var final_pos: Vector3 = player.global_position + forward * SCARE_DISTANCE
	start_pos.y = ground_y
	final_pos.y = ground_y + SCARE_LIFT

	global_position = start_pos
	_set_scare_pose()  # ค้างท่าเดียวกันทุกครั้ง
	_set_scare_orientation()

	# ล็อกผู้เล่น แล้วบังคับให้กล้องเล็งไปที่ใบหน้าผี
	var face_point := final_pos + Vector3(0.0, FACE_HEIGHT, 0.0)
	if player.has_method("lock_input"):
		player.lock_input(SCARE_LUNGE_TIME + SCARE_HOLD)
	if player.has_method("look_at_point"):
		player.look_at_point(face_point, 0.1)

	# พุ่งเข้าหา (ช้าก่อนแล้วเร็วขึ้นท้ายๆ)
	var lunge := create_tween()
	lunge.tween_property(self, "global_position", final_pos, SCARE_LUNGE_TIME) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	await lunge.finished

	# ถึงหน้าผู้เล่นแล้ว: หันหน้าเข้าหาอีกครั้งให้แม่นยำ
	_set_scare_orientation()

	# แสงส่องหน้า + เอฟเฟกต์ทั้งหมดพร้อมกัน
	# TODO: เสียง jumpscare ใส่ตรงนี้ทีหลัง
	if glow_light:
		var toward_player: Vector3 = player.global_position - final_pos
		toward_player.y = 0.0
		glow_light.global_position = face_point + toward_player.normalized() * 0.8	# ย้ายแสงมาอยู่หน้าใบหน้า
	glow_boost = SCARE_LIGHT_BOOST
	create_tween().tween_property(self, "glow_boost", 1.0, SCARE_HOLD)

	if screen_fx and screen_fx.has_method("flash"):
		screen_fx.flash(0.35, 0.8)
	if player.has_method("shake_camera"):
		player.shake_camera(0.2, 0.6)
	if player.has_method("punch_fov"):
		player.punch_fov(18.0, 0.5)
	if player.has_method("reduce_sanity"):
		player.reduce_sanity(SANITY_DAMAGE)

	await get_tree().create_timer(SCARE_HOLD).timeout

	# คืนค่าต่างๆ แล้ววาร์ปหนีไปจุดอื่น กลับไปเดินวนเหมือนเดิม
	glow_boost = 1.0
	if glow_light:
		glow_light.position = GLOW_LIGHT_POS
	rotation = Vector3(0.0, rotation.y, 0.0)	# เลิกเอนตัว กลับมาตั้งตรง
	_teleport_away()
	stare_time = 0.0
	static_value = 0.0
	creep_index = 0
	wait_timer = 0.0
	grace_timer = POST_SCARE_GRACE
	frozen = false
	_set_static(0.0)
	scaring = false

# วาร์ปไปที่จุดที่อยู่นอกสายตา และห่างจากผู้เล่นพอสมควร
func _teleport_away() -> void:
	if waypoints.is_empty():
		return

	var cam := get_viewport().get_camera_3d()
	var candidates: Array[Node3D] = []
	for p in waypoints:
		if p.global_position.distance_to(player.global_position) < TELEPORT_MIN_DISTANCE:
			continue
		if cam and cam.is_position_in_frustum(p.global_position + GAZE_TARGET_OFFSET):
			continue
		candidates.append(p)

	var chosen: Node3D = null
	if candidates.is_empty():
		# ไม่มีจุดที่เหมาะ: เลือกจุดที่ไกลผู้เล่นที่สุด
		var best := -1.0
		for p in waypoints:
			var d := p.global_position.distance_to(player.global_position)
			if d > best:
				best = d
				chosen = p
	else:
		chosen = candidates.pick_random()

	global_position = chosen.global_position
	target = chosen
	_pick_next_waypoint()

# ---------- ปุ่มทดสอบ (ตั้ง DEBUG_KEYS = false เมื่อเสร็จ) ----------
const _TEST_YAWS = [0.0, 45.0, 90.0, 135.0, 180.0, -135.0, -90.0, -45.0]
const _TEST_POSES = [0.0, 0.25, 0.5, 0.75]
var _test_yaw_index := 0
var _test_pose_index := 0

func _unhandled_input(event: InputEvent) -> void:
	if not DEBUG_KEYS:
		return
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return

	if key.keycode == KEY_J:
		if player == null:
			player = get_tree().get_first_node_in_group("player")
		if player != null and not scaring:
			print("JUMPSCARE ทดสอบ: ทิศหน้า = ", scare_yaw_fix_deg, " | ท่า = ", scare_pose_fraction, " | เอน = ", SCARE_TILT_DEG)
			_jumpscare()
	elif key.keycode == KEY_K:
		_test_yaw_index = (_test_yaw_index + 1) % _TEST_YAWS.size()
		scare_yaw_fix_deg = _TEST_YAWS[_test_yaw_index]
		print("ทิศหน้า SCARE_YAW_FIX_DEG = ", scare_yaw_fix_deg)
	elif key.keycode == KEY_L:
		_test_pose_index = (_test_pose_index + 1) % _TEST_POSES.size()
		scare_pose_fraction = _TEST_POSES[_test_pose_index]
		print("ท่าค้าง SCARE_POSE_FRACTION = ", scare_pose_fraction)

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

# เว้นว่างไว้ = ใช้อนิเมชันแรกที่เจอในโมเดล
@export var walk_animation: String = ""

var waypoints: Array[Node3D] = []
var target: Node3D = null
var wait_timer := 0.0
var anim: AnimationPlayer
var anim_playing := false

var player: CharacterBody3D = null
var screen_fx = null
var frozen := false					# true = กำลังถูกมอง แข็งทื่อ
var stare_time := 0.0
var static_value := 0.0
var grace_timer := START_GRACE
var scare_triggered := false

func _ready() -> void:
	add_to_group("ghost_girl")
	_find_waypoints()
	_setup_animation()
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

# ---------- ทุกเฟรม ----------
func _process(delta: float) -> void:
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
	var to_player := player.global_position - global_position
	_turn_toward(Vector3(to_player.x, 0.0, to_player.z), delta, 2.0)

func _turn_toward(flat_dir: Vector3, delta: float, speed_mult: float) -> void:
	if flat_dir.length() < 0.01:
		return
	var desired_yaw := atan2(-flat_dir.x, -flat_dir.z) + deg_to_rad(MODEL_YAW_OFFSET_DEG)
	rotation.y = lerp_angle(rotation.y, desired_yaw, clamp(TURN_SPEED * speed_mult * delta, 0.0, 1.0))

# ---------- ตรวจการถูกมอง (ต้องอยู่ใน physics เพราะใช้ raycast) ----------
func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as CharacterBody3D
		if player == null:
			return  # ยังไม่เจอ player (ตรวจว่าเพิ่ม add_to_group("player") ใน player.gd แล้ว)

	# ผู้เล่นตายแล้ว: เลิกตอบสนอง
	if player.get("is_dead"):
		_set_static(0.0)
		return

	# กำลังอ่านสมุด: ผีหยุดนิ่ง และไม่นับเวลาจ้อง
	if _notebook_open():
		frozen = true
		return

	if grace_timer > 0.0:
		grace_timer -= delta

	var seen := grace_timer <= 0.0 and _can_player_see_me()
	frozen = seen

	if seen:
		stare_time = minf(stare_time + delta, GAZE_TIME_TO_SCARE)
	else:
		stare_time = maxf(stare_time - delta * GAZE_DECAY_MULT, 0.0)
		if stare_time <= 0.0:
			scare_triggered = false

	if stare_time >= GAZE_TIME_TO_SCARE and not scare_triggered:
		scare_triggered = true
		_on_scare()

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

func _on_scare() -> void:
	# ขั้นที่ 3 จะเติม jumpscare ตรงนี้ (ตอนนี้แค่พิมพ์ข้อความทดสอบ)
	print("GhostGirl: จ้องครบ ", GAZE_TIME_TO_SCARE, " วินาที -> JUMPSCARE (ยังไม่ทำ)")

extends CharacterBody3D

# วิธีใช้: ทำ CrawlerGhost.tscn (root = CharacterBody3D + ลูกชื่อ "Model" เป็นโมเดล .glb) แล้วแนบสคริปต์นี้ที่ root
# ลากไฟล์ .tscn ลง level สคริปต์จะย้ายตัวเองไปเกิดห่างผู้เล่นเอง
# (ถ้าไม่มีลูกชื่อ Model สคริปต์จะโหลดโมเดลจาก MODEL_PATH ให้เอง)

# ---------- โมเดล ----------
const MODEL_PATH = "res://asset/Enemy/crawling_mutated_human.glb"
const MODEL_SCALE = 1.0				# ใช้เฉพาะตอนโหลดจาก MODEL_PATH (ถ้าใช้ .tscn ให้ปรับ Scale ของ node Model ใน Inspector)
const MODEL_OFFSET = Vector3(0.0, 0.0, 0.0)	# ขยับโมเดลเทียบกับจุดศูนย์กลางตัวผี (ถ้าลอยหรือจมพื้น ปรับ y)
const MODEL_YAW_OFFSET_DEG = 180.0	# ทิศหน้าของโมเดล (ถ้าคลานถอยหลัง ลอง 0)
const BODY_RADIUS = 0.4				# ขนาดตัวสำหรับชนกับต้นไม้/กำแพง

# ---------- เกิด ----------
const SPAWN_DISTANCE = 10.0			# เกิดห่างผู้เล่นประมาณกี่เมตร
const SPAWN_DISTANCE_JITTER = 2.0	# สุ่มคลาดเคลื่อน +/- กี่เมตร
const START_IDLE_TIME = 8.0			# ช่วงต้นเกมที่ผียังไม่ขยับ (วินาที)

# ---------- ขอบเขตแมพ ----------
const MAP_RADIUS = 45.0				# ผีเดินเล่นไม่ไกลเกินนี้จากจุดที่ผู้เล่นเริ่มเกม (ปรับให้พอดีกับแมพ)

# ---------- เดินเล่น ----------
const WANDER_SPEED = 1.8			# ความเร็วคลานตอนเดินเล่น (เมตร/วินาที)
const WANDER_MIN_DIST = 5.0			# จุดเดินเล่นถัดไปห่างอย่างน้อย
const WANDER_MAX_DIST = 14.0		# และไม่เกิน
const WAIT_MIN = 0.5				# หยุดพักที่แต่ละจุด
const WAIT_MAX = 2.0
const ARRIVE_DISTANCE = 0.8
const TURN_SPEED = 8.0

# ---------- วิ่งไล่ ----------
const CHASE_SPEED = 5.0				# ความเร็วตอนไล่ (ผู้เล่น: เดิน 3.5 / วิ่ง 8.0)
const ANIM_WANDER_SCALE = 1.0		# ความเร็วเล่นอนิเมชันตอนเดินเล่น
const ANIM_CHASE_SCALE = 1.8		# ความเร็วเล่นอนิเมชันตอนวิ่งไล่/หนี
const SIGHT_RANGE = 15.0			# มองเห็นผู้เล่นไกลสุด
const SIGHT_FOV_DEG = 140.0			# มุมมองของผี
const HEARING_RANGE = 3.5			# ใกล้กว่านี้รู้ตัวเสมอแม้ไม่เห็น
const LOSE_TIME = 5.0				# มองไม่เห็นผู้เล่นนานเท่านี้ ผีเลิกไล่
const SIGHT_BLOCK_MASK = 1			# collision layer ที่บังสายตา

# ---------- โจมตี ----------
const ATTACK_RANGE = 1.4			# ระยะที่โจมตีได้ (แนวราบ)
const ATTACK_VERTICAL = 1.8			# ผู้เล่นอยู่สูง/ต่ำกว่านี้ ผีโจมตีไม่ถึง (กันตีคนบน WatchTower)
const ATTACK_DAMAGE = 20.0			# HP ที่ลดต่อครั้ง
const ATTACK_COOLDOWN = 2.0			# ห่างกันกี่วินาทีต่อครั้ง
const ATTACK_PAUSE = 0.7			# ผีชะงักหลังโจมตีกี่วินาที
const STUMBLE_TIME = 0.9			# ผู้เล่นเดินสะดุดกี่วินาที
const STUMBLE_SLOW = 0.35			# ความเร็วผู้เล่นตอนสะดุด (0.35 = เหลือ 35%)

# ---------- ไฟฉายไล่ผี ----------
const FLASH_RANGE = 14.0			# ส่องถึงผีไกลสุด
const FLASH_HALF_ANGLE_DEG = 22.0	# ผีต้องอยู่ใกล้กลางจอไม่เกินกี่องศา
const FLASH_HOLD_TIME = 0.35		# ต้องส่องค้างกี่วินาทีผีถึงจะหนี
const FLEE_TIME = 10.0				# หนีนานกี่วินาทีก่อนกลับมาไล่
const FLEE_DISTANCE = 14.0			# หนีไปไกลกี่เมตรต่อช่วง
const TRACK_AFTER_FLEE = 12.0		# กลับมาไล่ใหม่ ผีรู้ตำแหน่งผู้เล่นตลอดกี่วินาที

# ---------- WatchTower (ผีห้ามเข้า) ----------
const TOWER_NODE_NAME = "WatchTower"	# ชื่อ node ของหอคอยใน level
const TOWER_MARGIN = 1.0			# ขยายพื้นที่ห้ามเข้ารอบหอคอยกี่เมตร

# ---------- สมุดโน้ต ----------
const FREEZE_WHEN_NOTEBOOK_OPEN = true	# ตอนเปิดสมุด ผีหยุดนิ่งเหมือน GhostGirl

# ---------- แสงเรือง (แดง) ----------
const GLOW_COLOR = Color(1.0, 0.1, 0.05)
const GLOW_LIGHT_ENERGY = 0.5
const GLOW_LIGHT_RANGE = 4.0
const GLOW_LIGHT_POS = Vector3(0.0, 0.5, 0.0)
const GLOW_PULSE_SPEED = 2.5
const GLOW_SHADER_CODE = """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_back;

uniform vec4 glow_color : source_color = vec4(1.0, 0.1, 0.05, 1.0);
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

enum State { IDLE, WANDER, CHASE, FLEE }

var state: State = State.IDLE
var player = null					# ไม่ระบุชนิด เพราะต้องเรียกฟังก์ชันของ player.gd
var spawned := false
var model: Node3D = null
var anim: AnimationPlayer = null
var anim_playing := false

var idle_timer := START_IDLE_TIME
var map_center := Vector3.ZERO
var facing := Vector3.FORWARD

var wander_target := Vector3.ZERO
var has_wander_target := false
var wander_wait := 0.0

var flee_target := Vector3.ZERO
var flee_timer := 0.0
var flash_timer := 0.0

var last_known := Vector3.ZERO
var lost_timer := 0.0
var track_timer := 0.0

var attack_cooldown := 0.0
var attack_pause := 0.0

var stuck_timer := 0.0
var stuck_pos := Vector3.ZERO

var tower_rect := Rect2()
var has_tower_rect := false

var want_dir := Vector3.ZERO
var want_speed := 0.0
var want_anim := 1.0

var glow_light: OmniLight3D = null
var glow_material: ShaderMaterial = null
var glow_time := 0.0

func _ready() -> void:
	add_to_group("crawler_ghost")
	collision_layer = 2		# อยู่คนละ layer กับโลก เพื่อไม่บังสายตา/ray ของระบบอื่น
	collision_mask = 1		# ชนกับพื้น ต้นไม้ กำแพง
	floor_snap_length = 0.6
	_setup_body()
	_setup_animation()
	_setup_glow()

# ---------- สร้างตัว ----------
func _setup_body() -> void:
	# ตัวชน: ถ้าใน .tscn ไม่ได้ใส่ CollisionShape3D ไว้ สคริปต์สร้างให้
	if find_children("*", "CollisionShape3D", false, false).is_empty():
		var shape := CollisionShape3D.new()
		var sphere := SphereShape3D.new()
		sphere.radius = BODY_RADIUS
		shape.shape = sphere
		shape.position = Vector3(0.0, BODY_RADIUS, 0.0)
		add_child(shape)

	# โมเดล: ใช้ node ลูกชื่อ "Model" ถ้ามี (วิธี .tscn) ไม่งั้นโหลดจาก MODEL_PATH
	model = get_node_or_null("Model") as Node3D
	if model == null:
		if not ResourceLoader.exists(MODEL_PATH):
			push_error("CrawlerGhost: ไม่พบโมเดลที่ " + MODEL_PATH + " (แก้ MODEL_PATH ด้านบนไฟล์)")
			return
		var scene := load(MODEL_PATH) as PackedScene
		if scene == null:
			push_error("CrawlerGhost: โหลดโมเดลไม่ได้")
			return
		model = scene.instantiate() as Node3D
		model.scale = Vector3.ONE * MODEL_SCALE
		model.position = MODEL_OFFSET
		add_child(model)
	model.rotation.y = deg_to_rad(MODEL_YAW_OFFSET_DEG)

	# กล้อง/แสงที่ติดมากับโมเดลไม่ต้องใช้
	for c in model.find_children("*", "Camera3D", true, false):
		c.queue_free()
	for l in model.find_children("*", "Light3D", true, false):
		l.queue_free()

func _setup_animation() -> void:
	if model == null:
		return
	anim = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if anim == null:
		push_warning("CrawlerGhost: ไม่พบ AnimationPlayer ในโมเดล")
		return
	if walk_animation == "":
		for n in anim.get_animation_list():
			if n != "RESET":
				walk_animation = n
				break
	print("CrawlerGhost animations: ", anim.get_animation_list(), " -> using: ", walk_animation)
	if walk_animation != "" and anim.has_animation(walk_animation):
		anim.get_animation(walk_animation).loop_mode = Animation.LOOP_LINEAR
		anim.play(walk_animation)
		anim.seek(0.0, true)
		anim.pause()
		anim_playing = false

func _set_anim(playing: bool, speed: float) -> void:
	if anim == null or walk_animation == "":
		return
	anim.speed_scale = speed
	if playing and not anim_playing:
		anim.play(walk_animation)
		anim_playing = true
	elif not playing and anim_playing:
		anim.pause()
		anim_playing = false

# ---------- แสงเรือง ----------
func _setup_glow() -> void:
	glow_light = OmniLight3D.new()
	glow_light.name = "GlowLight"
	glow_light.light_color = GLOW_COLOR
	glow_light.light_energy = GLOW_LIGHT_ENERGY
	glow_light.omni_range = GLOW_LIGHT_RANGE
	glow_light.shadow_enabled = false
	glow_light.position = GLOW_LIGHT_POS
	glow_light.add_to_group("ghost_light")	# ระบบ Sanity จะไม่นับแสงนี้เป็นที่สว่าง
	add_child(glow_light)

	if model == null:
		return
	var shader := Shader.new()
	shader.code = GLOW_SHADER_CODE
	glow_material = ShaderMaterial.new()
	glow_material.shader = shader
	glow_material.set_shader_parameter("glow_color", GLOW_COLOR)
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_overlay = glow_material

func _process(delta: float) -> void:
	glow_time += delta
	var pulse := 1.0 + 0.25 * sin(glow_time * GLOW_PULSE_SPEED)
	if glow_light:
		glow_light.light_energy = GLOW_LIGHT_ENERGY * pulse
	if glow_material:
		glow_material.set_shader_parameter("intensity", pulse)

# ---------- หอคอย ----------
func _compute_tower_rect() -> void:
	var tower := get_tree().current_scene.get_node_or_null(TOWER_NODE_NAME) as Node3D
	if tower == null:
		push_warning("CrawlerGhost: ไม่พบ node " + TOWER_NODE_NAME + " ใน level (ผีจะขึ้นหอคอยได้)")
		return
	var meshes := tower.find_children("*", "MeshInstance3D", true, false)
	if tower is MeshInstance3D:
		meshes.append(tower)
	var merged := AABB()
	var first := true
	for m in meshes:
		var mi := m as MeshInstance3D
		var box: AABB = mi.global_transform * mi.get_aabb()
		if first:
			merged = box
			first = false
		else:
			merged = merged.merge(box)
	if first:
		merged = AABB(tower.global_position - Vector3(5.0, 0.0, 5.0), Vector3(10.0, 10.0, 10.0))
	tower_rect = Rect2(merged.position.x, merged.position.z, merged.size.x, merged.size.z).grow(TOWER_MARGIN)
	has_tower_rect = true
	print("CrawlerGhost: พื้นที่ห้ามเข้ารอบหอคอย = ", tower_rect)

func _in_tower_zone(p: Vector3) -> bool:
	return has_tower_rect and tower_rect.has_point(Vector2(p.x, p.z))

# ถ้าผีเข้าไปในพื้นที่หอคอย ดันออกไปที่ขอบที่ใกล้ที่สุด (ผีจะไถลไปตามขอบเวลาไล่)
func _push_out_of_tower() -> void:
	if not has_tower_rect:
		return
	var p := Vector2(global_position.x, global_position.z)
	if not tower_rect.has_point(p):
		return
	var left := p.x - tower_rect.position.x
	var right := tower_rect.end.x - p.x
	var top := p.y - tower_rect.position.y
	var bottom := tower_rect.end.y - p.y
	var m := minf(minf(left, right), minf(top, bottom))
	var pos := global_position
	if m == left:
		pos.x = tower_rect.position.x - 0.05
	elif m == right:
		pos.x = tower_rect.end.x + 0.05
	elif m == top:
		pos.z = tower_rect.position.y - 0.05
	else:
		pos.z = tower_rect.end.y + 0.05
	global_position = pos

# ---------- ตำแหน่ง ----------
func _ground_at(p: Vector3) -> Variant:
	var query := PhysicsRayQueryParameters3D.create(p + Vector3.UP * 60.0, p + Vector3.DOWN * 60.0, SIGHT_BLOCK_MASK)
	if player != null:
		query.exclude = [player.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null
	if (hit["normal"] as Vector3).y < 0.7:
		return null
	return hit["position"]

func _outside_map(p: Vector3) -> bool:
	return Vector2(p.x - map_center.x, p.z - map_center.z).length() > MAP_RADIUS

func _spawn_near_player() -> void:
	_compute_tower_rect()
	map_center = player.global_position
	var placed := false
	for i in 30:
		var ang := randf() * TAU
		var d := SPAWN_DISTANCE + randf_range(-SPAWN_DISTANCE_JITTER, SPAWN_DISTANCE_JITTER)
		var p: Vector3 = player.global_position + Vector3(cos(ang), 0.0, sin(ang)) * d
		var g = _ground_at(p)
		if g == null or _in_tower_zone(g):
			continue
		global_position = (g as Vector3) + Vector3.UP * 0.1
		placed = true
		break
	if not placed:
		global_position = player.global_position + Vector3(SPAWN_DISTANCE, 0.0, 0.0)

	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0
	if to_player.length() > 0.01:
		facing = to_player.normalized()
		rotation.y = atan2(-facing.x, -facing.z)
	spawned = true

# ---------- ทุกเฟรมฟิสิกส์ ----------
func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return
		add_collision_exception_with(player)

	if not spawned:
		_spawn_near_player()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	want_dir = Vector3.ZERO
	want_speed = 0.0
	want_anim = ANIM_WANDER_SCALE

	var paused: bool = bool(player.get("is_dead")) or (FREEZE_WHEN_NOTEBOOK_OPEN and _notebook_open())
	if not paused:
		attack_cooldown -= delta
		attack_pause -= delta
		match state:
			State.IDLE:
				_state_idle(delta)
			State.WANDER:
				_state_wander(delta)
			State.CHASE:
				_state_chase(delta)
			State.FLEE:
				_state_flee(delta)

	_apply_movement(delta)
	move_and_slide()
	_push_out_of_tower()

func _apply_movement(delta: float) -> void:
	if want_speed > 0.0 and attack_pause <= 0.0:
		var d := want_dir
		facing = d
		rotation.y = lerp_angle(rotation.y, atan2(-d.x, -d.z), clampf(TURN_SPEED * delta, 0.0, 1.0))
		velocity.x = d.x * want_speed
		velocity.z = d.z * want_speed
		_set_anim(true, want_anim)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 30.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 30.0 * delta)
		_set_anim(false, 1.0)

# ---------- สถานะ ----------
func _state_idle(delta: float) -> void:
	idle_timer -= delta
	if idle_timer <= 0.0:
		state = State.WANDER
		has_wander_target = false
		wander_wait = 0.0

func _state_wander(delta: float) -> void:
	if _check_flashlight(delta):
		return
	if _can_sense_player():
		state = State.CHASE
		lost_timer = 0.0
		last_known = player.global_position
		return

	if wander_wait > 0.0:
		wander_wait -= delta
		return
	if not has_wander_target:
		_pick_wander_target()
		if not has_wander_target:
			wander_wait = 0.5
		return

	var to := wander_target - global_position
	to.y = 0.0
	if to.length() <= ARRIVE_DISTANCE or _is_stuck(delta):
		has_wander_target = false
		wander_wait = randf_range(WAIT_MIN, WAIT_MAX)
		return
	want_dir = to.normalized()
	want_speed = WANDER_SPEED
	want_anim = ANIM_WANDER_SCALE

func _state_chase(delta: float) -> void:
	if _check_flashlight(delta):
		return

	var sensed := _can_sense_player() or track_timer > 0.0
	track_timer = maxf(track_timer - delta, 0.0)
	if sensed:
		lost_timer = 0.0
		last_known = player.global_position
	else:
		lost_timer += delta
		if lost_timer >= LOSE_TIME:
			state = State.WANDER
			has_wander_target = false
			wander_wait = 0.5
			return

	# โจมตีถ้าอยู่ในระยะ
	var to_p: Vector3 = player.global_position - global_position
	var flat_dist := Vector2(to_p.x, to_p.z).length()
	if flat_dist <= ATTACK_RANGE and absf(to_p.y) <= ATTACK_VERTICAL and attack_cooldown <= 0.0:
		_attack()
		return

	var to := last_known - global_position
	to.y = 0.0
	if to.length() > 0.5:
		want_dir = to.normalized()
		want_speed = CHASE_SPEED
		want_anim = ANIM_CHASE_SCALE

func _state_flee(delta: float) -> void:
	flee_timer -= delta
	if flee_timer <= 0.0:
		state = State.CHASE
		track_timer = TRACK_AFTER_FLEE
		lost_timer = 0.0
		last_known = player.global_position
		return

	var to := flee_target - global_position
	to.y = 0.0
	if to.length() <= ARRIVE_DISTANCE or _is_stuck(delta):
		_pick_flee_target()
		return
	want_dir = to.normalized()
	want_speed = CHASE_SPEED
	want_anim = ANIM_CHASE_SCALE

# ---------- เดินเล่น ----------
func _pick_wander_target() -> void:
	stuck_timer = 0.0
	stuck_pos = global_position
	for i in 20:
		var ang := randf() * TAU
		var d := randf_range(WANDER_MIN_DIST, WANDER_MAX_DIST)
		var p := global_position + Vector3(cos(ang), 0.0, sin(ang)) * d
		if _outside_map(p):
			continue
		var g = _ground_at(p)
		if g == null or _in_tower_zone(g):
			continue
		wander_target = g
		has_wander_target = true
		return
	has_wander_target = false

# เดินแล้วไม่คืบหน้า (ติดต้นไม้/สิ่งกีดขวาง) -> true เพื่อให้เลือกจุดใหม่
func _is_stuck(delta: float) -> bool:
	stuck_timer += delta
	if stuck_timer < 1.0:
		return false
	stuck_timer = 0.0
	var moved := global_position.distance_to(stuck_pos)
	stuck_pos = global_position
	return moved < 0.3

# ---------- โจมตี ----------
func _attack() -> void:
	attack_cooldown = ATTACK_COOLDOWN
	attack_pause = ATTACK_PAUSE
	if player.has_method("take_damage"):
		player.take_damage(ATTACK_DAMAGE)
	if player.has_method("stumble"):
		player.stumble(STUMBLE_TIME, STUMBLE_SLOW)

# ---------- ไฟฉาย / หนี ----------
# คืนค่า true ถ้าเริ่มหนีในเฟรมนี้
func _check_flashlight(delta: float) -> bool:
	if _lit_by_flashlight():
		flash_timer += delta
	else:
		flash_timer = maxf(flash_timer - delta * 2.0, 0.0)
	if flash_timer >= FLASH_HOLD_TIME:
		flash_timer = 0.0
		state = State.FLEE
		flee_timer = FLEE_TIME
		_pick_flee_target()
		return true
	return false

func _lit_by_flashlight() -> bool:
	if not player.get("flashlight_on"):
		return false
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return false
	var point := global_position + Vector3(0.0, 0.4, 0.0)
	var to := point - cam.global_position
	if to.length() > FLASH_RANGE:
		return false
	var cam_forward := -cam.global_transform.basis.z
	if cam_forward.dot(to.normalized()) < cos(deg_to_rad(FLASH_HALF_ANGLE_DEG)):
		return false
	return _has_los(cam.global_position, point)

func _pick_flee_target() -> void:
	stuck_timer = 0.0
	stuck_pos = global_position
	var away: Vector3 = global_position - player.global_position
	away.y = 0.0
	if away.length() < 0.1:
		away = -facing
	away = away.normalized()
	for i in 16:
		var ang := deg_to_rad(randf_range(-70.0, 70.0))
		var dir := away.rotated(Vector3.UP, ang)
		var p := global_position + dir * FLEE_DISTANCE * randf_range(0.6, 1.0)
		if _outside_map(p):
			continue
		var g = _ground_at(p)
		if g == null or _in_tower_zone(g):
			continue
		flee_target = g
		return
	flee_target = global_position + away * FLEE_DISTANCE

# ---------- การรับรู้ ----------
func _can_sense_player() -> bool:
	var to_p: Vector3 = player.global_position - global_position
	var flat := Vector3(to_p.x, 0.0, to_p.z)
	var dist := flat.length()
	if dist <= HEARING_RANGE:
		return true
	if dist > SIGHT_RANGE:
		return false
	if facing.dot(flat.normalized()) < cos(deg_to_rad(SIGHT_FOV_DEG * 0.5)):
		return false
	return _has_los(global_position + Vector3(0.0, 0.4, 0.0), _player_eye())

func _player_eye() -> Vector3:
	var cam := get_viewport().get_camera_3d()
	if cam:
		return cam.global_position
	return player.global_position + Vector3(0.0, 1.4, 0.0)

func _has_los(from: Vector3, to: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(from, to, SIGHT_BLOCK_MASK)
	query.exclude = [player.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func _notebook_open() -> bool:
	var ui = get_tree().get_first_node_in_group("notebook_ui")
	return ui != null and ui.visible

extends CharacterBody3D

# วิธีใช้: ทำ CrawlerGhost.tscn (root = CharacterBody3D + ลูกชื่อ "Model" เป็นโมเดล .glb) แล้วแนบสคริปต์นี้ที่ root
# ลากไฟล์ .tscn ลง level ผีจะซ่อนอยู่จนกว่าเควส SPAWN_AFTER_QUEST จะสำเร็จ แล้วย้ายตัวเองไปเกิดห่างผู้เล่นเอง
# (ถ้าไม่มีลูกชื่อ Model สคริปต์จะโหลดโมเดลจาก MODEL_PATH ให้เอง)

# ---------- โมเดล ----------
const MODEL_PATH = "res://asset/Enemy/crawling_mutated_human.glb"
const MODEL_SCALE = 1.0				# ใช้เฉพาะตอนโหลดจาก MODEL_PATH (ถ้าใช้ .tscn ให้ปรับ Scale ของ node Model ใน Inspector)
const MODEL_OFFSET = Vector3(0.0, 0.0, 0.0)	# ขยับโมเดลเทียบกับจุดศูนย์กลางตัวผี (ถ้าลอยหรือจมพื้น ปรับ y)
const MODEL_YAW_OFFSET_DEG = 180.0	# ทิศหน้าของโมเดล (ถ้าคลานถอยหลัง ลอง 0)
const BODY_RADIUS = 0.4				# ขนาดตัวสำหรับชนกับต้นไม้/กำแพง
const BODY_LAYER = 2				# collision layer ของผี (คนละ layer กับโลก เพื่อไม่บังสายตา/ray ของระบบอื่น)
const BODY_MASK = 1					# ผีชนกับอะไร (พื้น ต้นไม้ กำแพง)

# ---------- เสียง ----------
# ถ้า path ไม่ตรง: คลิกขวาที่ไฟล์เสียงใน FileSystem > Copy Path แล้ววางแทน
const SOUND_HELP = "res://asset/Sound/Help.mp3"		# เล่นตอนเดินหาผู้เล่น
const SOUND_HUNT = "res://asset/Sound/Hunt.mp3"		# เล่นตอนวิ่งไล่
const SOUND_HURT = "res://asset/Sound/Hurt.mp3"		# เล่นตอนทำร้ายผู้เล่น
const HELP_VOLUME_DB = 0.0			# ความดังของแต่ละเสียง (ลบ = เบาลง, บวก = ดังขึ้น)
const HUNT_VOLUME_DB = 0.0
const HURT_VOLUME_DB = 3.0
const HELP_FIRST_DELAY = 3.0		# เริ่มเดินหาแล้วรอกี่วินาทีก่อนเล่นครั้งแรก
const HELP_GAP_MIN = 6.0			# ห่างกี่วินาทีระหว่างเสียง Help แต่ละครั้ง (นับหลังเสียงก่อนหน้าจบ)
const HELP_GAP_MAX = 12.0
const HUNT_GAP_MIN = 0.0			# ห่างกี่วินาทีระหว่างเสียง Hunt ตอนไล่ (0 = เล่นต่อเนื่อง)
const HUNT_GAP_MAX = 1.5
const AUDIO_UNIT_SIZE = 8.0			# ยิ่งมาก เสียงยิ่งได้ยินไกลก่อนจะเบาลง
const AUDIO_MAX_DISTANCE = 45.0		# ไกลกว่านี้ไม่ได้ยิน (เมตร)
const AUDIO_FADE_TIME = 0.4			# เสียงค่อยๆ เบาลงกี่วินาทีตอนเปลี่ยนสถานะ

# ---------- เงื่อนไขการเกิด ----------
const SPAWN_AFTER_QUEST = "find_watch_tower"	# id เควสที่ต้องสำเร็จก่อนผีจะเกิด (ตอนนี้คือเควสเก็บไฟฉาย) เว้นว่าง "" = เกิดตั้งแต่เริ่มเกม
const SPAWN_DELAY_AFTER_QUEST = 10.0			# หลังเควสสำเร็จ รออีกกี่วินาทีผีถึงจะเกิด (0 = เกิดทันที)
const SPAWN_OUT_OF_VIEW = true					# เกิดนอกกรอบภาพของผู้เล่นเสมอ (ไม่ให้เห็นตอนโผล่)

# ---------- เกิด ----------
const SPAWN_DISTANCE = 10.0			# เกิดห่างผู้เล่นประมาณกี่เมตร
const SPAWN_DISTANCE_JITTER = 2.0	# สุ่มคลาดเคลื่อน +/- กี่เมตร
const START_IDLE_TIME = 8.0			# หลังเกิดแล้ว ผียังไม่ขยับกี่วินาที (ถ้านานไป ลดค่านี้)

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
var dormant := true					# true = ยังไม่เกิด (ซ่อนอยู่)
var wake_timer := -1.0
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

# เสียง
var help_sound: AudioStreamPlayer3D = null
var hunt_sound: AudioStreamPlayer3D = null
var hurt_sound: AudioStreamPlayer3D = null
var fade_tweens := {}
var prev_state: State = State.IDLE
var help_gap := 0.0
var hunt_gap := 0.0

func _ready() -> void:
	add_to_group("crawler_ghost")
	floor_snap_length = 0.6
	_setup_body()
	_setup_animation()
	_setup_glow()
	_setup_audio()
	_go_dormant()	# ซ่อนไว้ก่อน จนกว่าเควสจะสำเร็จ

# ---------- ซ่อน / ปลุก ----------
func _go_dormant() -> void:
	dormant = true
	wake_timer = -1.0
	visible = false
	collision_layer = 0
	collision_mask = 0
	set_process(false)

func _quest_done() -> bool:
	if SPAWN_AFTER_QUEST == "":
		return true
	return QuestManager.done.has(SPAWN_AFTER_QUEST)

func _check_wake(delta: float) -> void:
	if not _quest_done():
		wake_timer = -1.0
		return
	if wake_timer < 0.0:
		wake_timer = SPAWN_DELAY_AFTER_QUEST if SPAWN_AFTER_QUEST != "" else 0.0
	wake_timer -= delta
	if wake_timer <= 0.0:
		_wake_up()

func _wake_up() -> void:
	dormant = false
	collision_layer = BODY_LAYER
	collision_mask = BODY_MASK
	velocity = Vector3.ZERO
	idle_timer = START_IDLE_TIME
	state = State.IDLE
	prev_state = State.IDLE
	help_gap = HELP_FIRST_DELAY
	_spawn_near_player()
	visible = true
	set_process(true)
	print("CrawlerGhost: เกิดแล้ว (เควส '", SPAWN_AFTER_QUEST, "' สำเร็จ)")

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

# ---------- เสียง ----------
func _setup_audio() -> void:
	help_sound = _make_audio(SOUND_HELP, HELP_VOLUME_DB)
	hunt_sound = _make_audio(SOUND_HUNT, HUNT_VOLUME_DB)
	hurt_sound = _make_audio(SOUND_HURT, HURT_VOLUME_DB)

func _make_audio(path: String, volume_db: float) -> AudioStreamPlayer3D:
	var p := AudioStreamPlayer3D.new()
	p.unit_size = AUDIO_UNIT_SIZE
	p.max_distance = AUDIO_MAX_DISTANCE
	p.volume_db = volume_db
	p.position = Vector3(0.0, 0.5, 0.0)
	if ResourceLoader.exists(path):
		p.stream = load(path) as AudioStream
	else:
		push_warning("CrawlerGhost: ไม่พบไฟล์เสียง " + path + " (แก้ path ด้านบนไฟล์)")
	add_child(p)
	return p

func _play_sound(p: AudioStreamPlayer3D, base_db: float, key: String) -> void:
	if p == null or p.stream == null:
		return
	_kill_fade(key)
	p.volume_db = base_db
	p.play()

func _is_fading(key: String) -> bool:
	var t = fade_tweens.get(key)
	return t != null and t.is_valid()

func _kill_fade(key: String) -> void:
	var t = fade_tweens.get(key)
	if t != null and t.is_valid():
		t.kill()
	fade_tweens.erase(key)

# ค่อยๆ เบาลงจนเงียบแล้วหยุด (เรียกซ้ำได้ ไม่เริ่ม fade ใหม่ถ้ากำลัง fade อยู่)
func _fade_out(p: AudioStreamPlayer3D, base_db: float, key: String) -> void:
	if p == null or not p.playing or _is_fading(key):
		return
	var t := create_tween()
	t.tween_property(p, "volume_db", -40.0, AUDIO_FADE_TIME)
	t.tween_callback(_stop_sound.bind(p, base_db))
	fade_tweens[key] = t

func _stop_sound(p: AudioStreamPlayer3D, base_db: float) -> void:
	p.stop()
	p.volume_db = base_db

func _on_state_changed(new_state: State) -> void:
	match new_state:
		State.CHASE:
			# เริ่มไล่: เสียง Help เบาลง เสียง Hunt เล่นทันที
			_fade_out(help_sound, HELP_VOLUME_DB, "help")
			_play_sound(hunt_sound, HUNT_VOLUME_DB, "hunt")
			hunt_gap = randf_range(HUNT_GAP_MIN, HUNT_GAP_MAX)
		State.WANDER:
			# กลับมาเดินหา: เสียง Hunt เบาลง แล้วรอสักครู่ก่อนเสียง Help
			_fade_out(hunt_sound, HUNT_VOLUME_DB, "hunt")
			help_gap = HELP_FIRST_DELAY
		_:
			# หยุดนิ่ง หรือกำลังหนีไฟฉาย: เงียบ
			_fade_out(help_sound, HELP_VOLUME_DB, "help")
			_fade_out(hunt_sound, HUNT_VOLUME_DB, "hunt")

func _update_audio(delta: float) -> void:
	# ผู้เล่นตายแล้ว: เสียงค่อยๆ เงียบ
	if bool(player.get("is_dead")):
		_fade_out(help_sound, HELP_VOLUME_DB, "help")
		_fade_out(hunt_sound, HUNT_VOLUME_DB, "hunt")
		return

	if state != prev_state:
		prev_state = state
		_on_state_changed(state)

	match state:
		State.WANDER:
			if help_sound and not help_sound.playing:
				help_gap -= delta
				if help_gap <= 0.0:
					_play_sound(help_sound, HELP_VOLUME_DB, "help")
					help_gap = randf_range(HELP_GAP_MIN, HELP_GAP_MAX)
		State.CHASE:
			if hunt_sound and not hunt_sound.playing:
				hunt_gap -= delta
				if hunt_gap <= 0.0:
					_play_sound(hunt_sound, HUNT_VOLUME_DB, "hunt")
					hunt_gap = randf_range(HUNT_GAP_MIN, HUNT_GAP_MAX)

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
	var cam := get_viewport().get_camera_3d()
	var fallback := Vector3.ZERO
	var has_fallback := false
	var placed := false

	for i in 40:
		var ang := randf() * TAU
		var d := SPAWN_DISTANCE + randf_range(-SPAWN_DISTANCE_JITTER, SPAWN_DISTANCE_JITTER)
		var p: Vector3 = player.global_position + Vector3(cos(ang), 0.0, sin(ang)) * d
		var g = _ground_at(p)
		if g == null or _in_tower_zone(g):
			continue
		var pos: Vector3 = (g as Vector3) + Vector3.UP * 0.1
		if not has_fallback:
			fallback = pos
			has_fallback = true
		# ไม่เกิดในกรอบภาพของผู้เล่น (กันผีโผล่ต่อหน้า)
		if SPAWN_OUT_OF_VIEW and cam and cam.is_position_in_frustum(pos + Vector3(0.0, 0.5, 0.0)):
			continue
		global_position = pos
		placed = true
		break

	if not placed:
		if has_fallback:
			global_position = fallback
		else:
			global_position = player.global_position + Vector3(SPAWN_DISTANCE, 0.0, 0.0)

	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0
	if to_player.length() > 0.01:
		facing = to_player.normalized()
		rotation.y = atan2(-facing.x, -facing.z)

# ---------- ทุกเฟรมฟิสิกส์ ----------
func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return
		add_collision_exception_with(player)
		map_center = player.global_position	# จุดเริ่มเกมของผู้เล่น = ศูนย์กลางขอบเขตแมพ

	# ยังไม่เกิด: คอยเช็คเควสอย่างเดียว
	if dormant:
		_check_wake(delta)
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
	_update_audio(delta)

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
	_play_sound(hurt_sound, HURT_VOLUME_DB, "hurt")
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

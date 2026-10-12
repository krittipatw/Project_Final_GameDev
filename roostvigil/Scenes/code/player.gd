extends CharacterBody3D

const WALK_SPEED = 3.5
const SPRINT_SPEED = 8.0
const CROUCH_SPEED = 2.5
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003
const MAX_STEP_HEIGHT = 0.4
const STEP_FORWARD_DIST = 0.1	# ระยะก้าวไปข้างหน้าขั้นต่ำตอนขึ้นขั้น (ไม่ขึ้นกับความเร็ว)

# ตัวแปรสำหรับความเร็วปัจจุบัน
var current_speed = WALK_SPEED

# Head bob (เดิน/วิ่ง)
const BOB_FREQ = 2.0
const BOB_AMP = 0.06
const BOB_HORIZONTAL = 0.03
var bob_time := 0.0
var head_start_y := 0.0

# ระบบย่อตัว (Crouch)
const CROUCH_DEPTH = 0.5		# ระยะยุบตัวลงไปเมื่อย่อ
var head_crouch_y := 0.0
const LERP_VAL = 10.0

# ระบบ Stamina (หน่วยเป็น "วินาทีที่วิ่งได้")
const STAMINA_MAX = 20.0				# วิ่งต่อเนื่องได้สูงสุดกี่วินาที
const STAMINA_DRAIN_PER_SEC = 1.0		# ตอนวิ่ง ลดวินาทีละเท่าไหร่
const STAMINA_RECHARGE_PER_SEC = 2.0	# ตอนไม่วิ่ง เพิ่มวินาทีละเท่าไหร่ (0 -> 10 ใช้ 5 วิ)
const STAMINA_RESUME_AT = 10.0			# หมดแล้วต้องชาร์จถึงเท่านี้ถึงจะวิ่งได้อีก
var stamina := STAMINA_MAX
var exhausted := false					# true = หมดแรง กำลังพัก วิ่งไม่ได้

# ระบบไฟฉาย (Flashlight)
const BATTERY_DRAIN_PER_SEC = 1.0	# ลดกี่ % ต่อวินาที
const BATTERY_MAX = 100.0
var has_flashlight := false
var flashlight_on := false
var battery := BATTERY_MAX

# ---------- ระบบ HP ----------
const HP_MAX = 100.0
const HP_REGEN_PER_SEC = 1.0		# เพิ่มเมื่อ Sanity เต็มเท่านั้น
const HP_DRAIN_PER_SEC = 1.0		# ลดเมื่อ Sanity เป็น 0
const HP_CRITICAL = 30.0			# HP ต่ำกว่าหรือเท่านี้ = ก้มต่ำ วิ่งไม่ได้
const HURT_DEPTH = 0.3				# ระยะที่กล้องก้มต่ำลงตอน HP วิกฤต
# ข้อความตามระดับ HP (1 = 75, 2 = 50, 3 = 30)
const HP_MESSAGES = {
	1: "Ouch! What was that?",
	2: "It's hurt! I need to recovery.",
	3: "I can't take it ANYMORE.",
}
# ความเข้มขอบแดงของแต่ละระดับ (ลำดับ 0, 1, 2, 3)
const HP_VIGNETTE = [0.0, 0.25, 0.5, 0.9]
var hp := HP_MAX
var hp_tier := 0
var vignette_value := 0.0
var is_dead := false

# ---------- ระบบ Sanity ----------
const SANITY_MAX = 100.0
const SANITY_DRAIN_PER_SEC = 1.0	# ลดตอนอยู่ในที่มืด
const SANITY_RECOVER_PER_SEC = 1.0	# เพิ่มตอนอยู่ในที่สว่าง
const LIGHT_CHECK_INTERVAL = 0.5	# ตรวจแสงรอบตัวทุกกี่วินาที
const LIGHT_RANGE_SCALE = 1.0		# คูณระยะแสงของโคมแต่ละดวง (ลดเป็น 0.8 ถ้าอยากให้ต้องเข้าใกล้กว่านี้)
# ข้อความตามระดับ Sanity (1 = 50, 2 = ต่ำกว่า 30, 3 = 20, 4 = 10, 5 = 0)
const SANITY_MESSAGES = {
	1: "I'm scared..",
	2: "I can't..",
	3: "I'm scared of the DARK..",
	4: "I don't think I can make it..",
	5: "I can't CONTROL myself!!",
}
var sanity := SANITY_MAX
var sanity_tier := 0
var in_light := true
var light_check_timer := 0.0
var blink_timer := 3.0

# ข้อความแจ้งเตือน
var message_token := 0

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var interact_ray: RayCast3D = $Head/Camera3D/InteractRay
@onready var flashlight_light: SpotLight3D = $Head/Camera3D/Flashlight

@onready var _scene = get_tree().current_scene
@onready var prompt_label: Label = _scene.get_node_or_null("CanvasLayer/PromptLabel")
@onready var battery_label: Label = _scene.get_node_or_null("CanvasLayer/BatteryLabel")
@onready var message_label: Label = _scene.get_node_or_null("CanvasLayer/MessageLabel")
@onready var stamina_bar: ProgressBar = _scene.get_node_or_null("CanvasLayer/StaminaBar")
@onready var hp_bar: ProgressBar = _scene.get_node_or_null("CanvasLayer/HPBar")
@onready var hp_text: Label = _scene.get_node_or_null("CanvasLayer/HPBar/Label")
@onready var sanity_bar: ProgressBar = _scene.get_node_or_null("CanvasLayer/SanityBar")
@onready var sanity_text: Label = _scene.get_node_or_null("CanvasLayer/SanityBar/Label")
@onready var vignette: ColorRect = _scene.get_node_or_null("EffectsLayer/Vignette")
@onready var blink_overlay: ColorRect = _scene.get_node_or_null("EffectsLayer/BlinkOverlay")
@onready var death_fade: ColorRect = _scene.get_node_or_null("GameOverLayer/DeathFade")
@onready var game_over_ui: Control = _scene.get_node_or_null("GameOverLayer/GameOverUI")
@onready var restart_button: Button = _scene.get_node_or_null("GameOverLayer/GameOverUI/RestartButton")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	head_start_y = head.position.y
	head_crouch_y = head_start_y - CROUCH_DEPTH

	if prompt_label:
		prompt_label.visible = false
	else:
		push_warning("PromptLabel not found - ตรวจ path ของ prompt_label")

	if battery_label:
		battery_label.visible = false
	else:
		push_warning("BatteryLabel not found - ตรวจ path ของ battery_label")

	if message_label:
		message_label.visible = false
	else:
		push_warning("MessageLabel not found - ตรวจ path ของ message_label")

	if stamina_bar:
		stamina_bar.max_value = STAMINA_MAX
		stamina_bar.value = STAMINA_MAX
		stamina_bar.visible = false
	else:
		push_warning("StaminaBar not found - ตรวจ path ของ stamina_bar")

	if hp_bar:
		hp_bar.max_value = HP_MAX
	else:
		push_warning("HPBar not found - ตรวจ path ของ hp_bar")

	if sanity_bar:
		sanity_bar.max_value = SANITY_MAX
	else:
		push_warning("SanityBar not found - ตรวจ path ของ sanity_bar")

	if vignette == null:
		push_warning("Vignette not found - ตรวจ EffectsLayer/Vignette")

	if blink_overlay:
		blink_overlay.visible = true
		blink_overlay.modulate.a = 0.0
	else:
		push_warning("BlinkOverlay not found - ตรวจ EffectsLayer/BlinkOverlay")

	if death_fade:
		death_fade.visible = true
		death_fade.modulate.a = 0.0
	else:
		push_warning("DeathFade not found - ตรวจ GameOverLayer/DeathFade")

	if game_over_ui:
		game_over_ui.visible = false
	else:
		push_warning("GameOverUI not found - ตรวจ GameOverLayer/GameOverUI")

	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)

	if flashlight_light:
		flashlight_light.visible = false
	else:
		push_warning("Flashlight (SpotLight3D) not found - ตรวจชื่อ node ว่าเป็น Flashlight")

	if interact_ray == null:
		push_warning("InteractRay not found - ตรวจ path ของ interact_ray")

	_update_hp_bar()
	_update_sanity_bar()

# ---------- State ----------
func _ui_open() -> bool:
	var ui = get_tree().get_first_node_in_group("notebook_ui")
	return ui != null and ui.visible

func _can_control() -> bool:
	return not is_dead and not _ui_open() and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

# ---------- Input ----------
func _unhandled_input(event: InputEvent) -> void:
	# ตายแล้ว ไม่รับการควบคุมใดๆ
	if is_dead:
		return

	# ถ้า UI สมุดเปิดอยู่ ไม่หมุนกล้อง ไม่ interact
	if _ui_open():
		return

	# เมาส์ถูกปลดอยู่ (กด ESC ไว้) คลิกเพื่อกลับเข้าเกม
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseButton and event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

	if event.is_action_pressed("Interact"):
		_try_interact()

	if event.is_action_pressed("flashlight"):
		_toggle_flashlight()

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# ---------- Message ----------
func show_message(text: String, duration: float = 2.0) -> void:
	if message_label == null:
		return
	message_token += 1
	var token := message_token
	message_label.text = text
	message_label.visible = true
	await get_tree().create_timer(duration).timeout
	# ซ่อนเฉพาะเมื่อไม่มีข้อความใหม่มาแทนที่ระหว่างรอ
	if token == message_token and message_label:
		message_label.visible = false

# ---------- Stamina ----------
# คืนค่า true ถ้า "กำลังวิ่งจริง" ในเฟรมนี้
func _update_stamina(delta: float, wants_sprint: bool, moving: bool) -> bool:
	var sprinting := false

	if exhausted:
		# กำลังพักอยู่ วิ่งไม่ได้ ถ้ากดวิ่งใหม่ให้ขึ้นข้อความ (เฉพาะตอนเพิ่งกด ไม่รัวทุกเฟรม)
		if wants_sprint and Input.is_action_just_pressed("sprint"):
			show_message("I need to rest a bit")
	elif wants_sprint and moving:
		sprinting = true

	if sprinting:
		stamina -= STAMINA_DRAIN_PER_SEC * delta
		if stamina <= 0.0:
			stamina = 0.0
			exhausted = true
			sprinting = false
			show_message("I'm too tired.")
	else:
		stamina = min(stamina + STAMINA_RECHARGE_PER_SEC * delta, STAMINA_MAX)
		if exhausted and stamina >= STAMINA_RESUME_AT:
			exhausted = false

	_update_stamina_bar(sprinting)
	return sprinting

func _update_stamina_bar(sprinting: bool) -> void:
	if stamina_bar == null:
		return
	stamina_bar.value = stamina
	# เต็มและไม่ได้วิ่ง = ซ่อน
	stamina_bar.visible = stamina < STAMINA_MAX or sprinting

# ---------- Sanity ----------
func _sanity_tier_for(value: float) -> int:
	if value <= 0.0:
		return 5
	elif value <= 10.0:
		return 4
	elif value <= 20.0:
		return 3
	elif value < 30.0:
		return 2
	elif value <= 50.0:
		return 1
	return 0

func _update_sanity(delta: float) -> void:
	# ตรวจแสงรอบตัวเป็นช่วงๆ (ไม่ต้องทุกเฟรม)
	light_check_timer -= delta
	if light_check_timer <= 0.0:
		light_check_timer = LIGHT_CHECK_INTERVAL
		in_light = _is_in_light()

	if in_light:
		sanity = min(sanity + SANITY_RECOVER_PER_SEC * delta, SANITY_MAX)
	else:
		sanity = max(sanity - SANITY_DRAIN_PER_SEC * delta, 0.0)

	# ข้ามระดับลงมาถึงขึ้นข้อความ (ขึ้นกลับไปไม่ขึ้น)
	var new_tier := _sanity_tier_for(sanity)
	if new_tier > sanity_tier and SANITY_MESSAGES.has(new_tier):
		show_message(SANITY_MESSAGES[new_tier], 3.0)
	sanity_tier = new_tier

	_update_sanity_bar()

# [GHOST] ลด Sanity ทันที เรียกจากผี/ศัตรู เช่น player.lose_sanity(20)
func lose_sanity(amount: float) -> void:
	if is_dead:
		return
	sanity = max(sanity - amount, 0.0)
	var new_tier := _sanity_tier_for(sanity)
	if new_tier > sanity_tier and SANITY_MESSAGES.has(new_tier):
		show_message(SANITY_MESSAGES[new_tier], 3.0)
	sanity_tier = new_tier
	_update_sanity_bar()

# อยู่ในที่สว่างไหม: เปิดไฟฉาย หรืออยู่ในระยะแสงของโคมที่เปิดอยู่
func _is_in_light() -> bool:
	if flashlight_on:
		return true

	for node in get_tree().root.find_children("*", "Light3D", true, false):
		# [GHOST] ข้ามไฟฉายตัวเอง และแสงเรืองของผี (group ghost_light)
		if node == flashlight_light or node.is_in_group("ghost_light"):
			continue
		var light := node as Light3D
		if light == null or not light.is_visible_in_tree() or light.light_energy <= 0.0:
			continue

		var light_range := 0.0
		if node is OmniLight3D:
			light_range = (node as OmniLight3D).omni_range
		elif node is SpotLight3D:
			light_range = (node as SpotLight3D).spot_range
		else:
			continue  # DirectionalLight3D (แสงจันทร์) ไม่นับ

		if global_position.distance_to(light.global_position) <= light_range * LIGHT_RANGE_SCALE:
			return true
	return false

func _update_sanity_bar() -> void:
	if sanity_bar:
		sanity_bar.value = sanity
	if sanity_text:
		sanity_text.text = "Sanity %d/%d" % [ceili(sanity), int(SANITY_MAX)]

# กะพริบตา: ถี่ขึ้นตามระดับ Sanity ที่ลดลง
func _blink_interval() -> float:
	if sanity_tier >= 4:
		return 3.0
	elif sanity_tier == 3:
		return 5.0
	elif sanity_tier == 2:
		return 8.0
	return 0.0  # Sanity ยังไม่ต่ำพอ ไม่กะพริบ

func _update_blink(delta: float) -> void:
	if blink_overlay == null:
		return
	var interval := _blink_interval()
	if interval <= 0.0:
		return
	blink_timer -= delta
	if blink_timer <= 0.0:
		_do_blink()
		blink_timer = randf_range(interval * 0.6, interval * 1.4)

func _do_blink() -> void:
	var tween := create_tween()
	tween.tween_property(blink_overlay, "modulate:a", 1.0, 0.07)
	tween.tween_interval(0.05)
	tween.tween_property(blink_overlay, "modulate:a", 0.0, 0.15)

# ---------- HP ----------
func _hp_tier_for(value: float) -> int:
	if value <= 30.0:
		return 3
	elif value <= 50.0:
		return 2
	elif value <= 75.0:
		return 1
	return 0

func _update_hp(delta: float) -> void:
	if sanity <= 0.0:
		hp -= HP_DRAIN_PER_SEC * delta
	elif sanity >= SANITY_MAX and hp < HP_MAX:
		hp += HP_REGEN_PER_SEC * delta
	_apply_hp_change()

# เรียกจาก Enemy ได้เลย เช่น player.take_damage(30)
func take_damage(amount: float) -> void:
	if is_dead:
		return
	hp -= amount
	_apply_hp_change()

func heal(amount: float) -> void:
	if is_dead:
		return
	hp += amount
	_apply_hp_change()

func _apply_hp_change() -> void:
	hp = clamp(hp, 0.0, HP_MAX)

	var new_tier := _hp_tier_for(hp)
	if new_tier > hp_tier and HP_MESSAGES.has(new_tier):
		show_message(HP_MESSAGES[new_tier], 3.0)
	hp_tier = new_tier

	_update_hp_bar()

	if hp <= 0.0 and not is_dead:
		_game_over()

func _update_hp_bar() -> void:
	if hp_bar:
		hp_bar.value = hp
	if hp_text:
		hp_text.text = "HP %d/%d" % [ceili(hp), int(HP_MAX)]

# ขอบจอแดงตามระดับ HP (ค่อยๆ เปลี่ยน ไม่วูบ)
func _update_vignette(delta: float) -> void:
	if vignette == null:
		return
	var target: float = HP_VIGNETTE[hp_tier]
	vignette_value = lerpf(vignette_value, target, delta * 3.0)
	var mat := vignette.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("intensity", vignette_value)

# ---------- Game Over ----------
func _game_over() -> void:
	is_dead = true
	if prompt_label:
		prompt_label.visible = false

	var tween := create_tween()
	if death_fade:
		tween.tween_property(death_fade, "modulate:a", 1.0, 3.0)
	tween.tween_callback(_show_game_over_ui)

func _show_game_over_ui() -> void:
	if game_over_ui:
		game_over_ui.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

# ---------- Flashlight ----------
func pick_up_flashlight() -> void:
	has_flashlight = true
	if battery_label:
		battery_label.visible = true
	_update_battery_label()

func add_battery(amount: float) -> void:
	battery = clamp(battery + amount, 0.0, BATTERY_MAX)
	_update_battery_label()

# เรียกจาก BatteryPickup คืนค่า true ถ้าเก็บสำเร็จ (แบตก้อนนั้นจะหายไป)
func try_add_battery(amount: float) -> bool:
	if not has_flashlight:
		show_message("You need a flashlight first")
		return false
	# แบตเกิน (100 - amount) เช่น 76% ขึ้นไป ถือว่ายังพอ เก็บไม่ได้
	if battery > BATTERY_MAX - amount:
		show_message("Battery still good")
		return false
	add_battery(amount)
	return true

func _toggle_flashlight() -> void:
	if not has_flashlight:
		return
	if flashlight_on:
		_set_flashlight(false)
	elif battery > 0.0:
		_set_flashlight(true)

func _set_flashlight(value: bool) -> void:
	flashlight_on = value
	if flashlight_light:
		flashlight_light.visible = value

func _update_battery_label() -> void:
	if battery_label:
		battery_label.text = "Battery: %d%%" % ceili(battery)

func _process(delta: float) -> void:
	if is_dead:
		return

	# แบตเตอรี่ไฟฉาย
	if flashlight_on:
		battery -= BATTERY_DRAIN_PER_SEC * delta
		if battery <= 0.0:
			battery = 0.0
			_set_flashlight(false)
		_update_battery_label()

	_update_sanity(delta)
	_update_hp(delta)
	_update_vignette(delta)
	_update_blink(delta)

# ---------- Movement ----------
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var can_control := _can_control()

	var input_dir := Vector2.ZERO
	if can_control:
		input_dir = Input.get_vector("move-left", "move-right", "move-forward", "move-backward")
		# Sanity หมด: ปุ่มเดินสลับด้านทั้งหน้า/หลัง ซ้าย/ขวา
		if sanity <= 0.0:
			input_dir = -input_dir

	# --- จัดการเรื่องความเร็ว (Sprint / Crouch / Walk) ---
	var is_crouching := false
	var wants_sprint := false

	if can_control:
		is_crouching = Input.is_action_pressed("crouch")
		# HP วิกฤต (<= 30) วิ่งไม่ได้
		wants_sprint = Input.is_action_pressed("sprint") and not is_crouching and hp > HP_CRITICAL

	# ผ่านระบบ Stamina ก่อนว่าวิ่งได้จริงไหม
	var is_sprinting := _update_stamina(delta, wants_sprint, input_dir != Vector2.ZERO)

	if is_crouching:
		current_speed = CROUCH_SPEED
	elif is_sprinting:
		current_speed = SPRINT_SPEED
	else:
		current_speed = WALK_SPEED

	# กระโดด (ถ้ากำลังย่อตัวอยู่ จะไม่อนุญาตให้กระโดด)
	if can_control and Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = JUMP_VELOCITY

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = 0
		velocity.z = 0

	var was_on_floor := is_on_floor()
	var start_position := global_position
	var start_velocity := velocity

	move_and_slide()

	if was_on_floor and is_on_wall() and direction != Vector3.ZERO and velocity.y <= 0.0:
		_try_step_up(start_position, start_velocity, delta)

	_update_head_bob(delta, is_sprinting, is_crouching)
	_update_prompt()

# ---------- Head Bob & Crouch Position ----------
func _update_head_bob(delta: float, is_sprinting: bool, is_crouching: bool) -> void:
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()

	# ปรับความถี่ Head Bob ตอนวิ่งให้เร็วขึ้นนิดหน่อย
	var current_bob_freq = BOB_FREQ * 1.3 if is_sprinting else BOB_FREQ
	var current_bob_amp = BOB_AMP * 1.5 if is_sprinting else BOB_AMP

	# ตำแหน่งเป้าหมายความสูงของ Head (ย่อตัว / HP วิกฤตก้มต่ำ / ปกติ)
	var target_y := head_start_y
	if is_crouching:
		target_y = head_crouch_y
	elif hp_tier >= 3:
		target_y = head_start_y - HURT_DEPTH

	if is_on_floor() and horizontal_speed > 0.1 and not is_crouching:
		bob_time += delta * horizontal_speed
		var target := Vector3(
			cos(bob_time * current_bob_freq * 0.5) * BOB_HORIZONTAL,
			target_y + sin(bob_time * current_bob_freq) * current_bob_amp,
			0.0
		)
		head.position = head.position.lerp(target, delta * LERP_VAL)
	else:
		# ถ้าไม่ได้เคลื่อนไหว หรือกำลังย่อตัว ค่อยๆ Smooth ตำแหน่งความสูง Head ไปที่เป้าหมาย
		var rest := Vector3(0.0, target_y, 0.0)
		head.position = head.position.lerp(rest, delta * LERP_VAL)

# ---------- Interact ----------
func _get_interactable() -> Object:
	if interact_ray and interact_ray.is_colliding():
		var target = interact_ray.get_collider()
		if target and target.has_method("interact"):
			return target
	return null

func _try_interact() -> void:
	var target = _get_interactable()
	if target:
		target.interact(self)

func _update_prompt() -> void:
	if prompt_label == null:
		return

	if is_dead or _ui_open():
		prompt_label.visible = false
		return

	var target = _get_interactable()
	if target:
		var text := "Interact"
		if target.has_method("get_prompt"):
			text = target.get_prompt()
		prompt_label.text = "[E] " + text
		prompt_label.visible = true
	else:
		prompt_label.visible = false

# ---------- Step Up ----------
func _try_step_up(start_position: Vector3, start_velocity: Vector3, delta: float) -> void:
	var end_position := global_position

	# 1) ย้อนกลับไปตำแหน่งก่อนชน แล้วยกขึ้นตามความสูงขั้นบันได
	global_position = start_position
	var up_motion := Vector3.UP * MAX_STEP_HEIGHT
	var up_collision := KinematicCollision3D.new()
	if test_move(global_transform, up_motion, up_collision):
		up_motion = up_collision.get_travel()
	global_position += up_motion

	# 2) ก้าวไปข้างหน้า (ใช้ระยะขั้นต่ำ เพื่อให้เดินช้าก็ขึ้นขั้นได้)
	var horizontal_vel := Vector3(start_velocity.x, 0, start_velocity.z)
	var forward_motion := horizontal_vel.normalized() * maxf(horizontal_vel.length() * delta, STEP_FORWARD_DIST)
	if test_move(global_transform, forward_motion):
		global_position = end_position
		return
	global_position += forward_motion

	# 3) กดตัวลงมาให้ติดพื้นขั้นบันได
	var down_collision := KinematicCollision3D.new()
	if test_move(global_transform, Vector3.DOWN * (up_motion.y + 0.05), down_collision):
		if down_collision.get_normal().angle_to(Vector3.UP) <= floor_max_angle:
			global_position += down_collision.get_travel()
			return

	# 4) ถ้าไม่ผ่านเงื่อนไข ให้กลับตำแหน่งเดิม
	global_position = end_position

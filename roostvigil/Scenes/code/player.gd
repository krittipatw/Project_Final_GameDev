extends CharacterBody3D

const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const CROUCH_SPEED = 2.5
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003
const MAX_STEP_HEIGHT = 0.4

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

# ข้อความแจ้งเตือน
var message_token := 0

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var interact_ray: RayCast3D = $Head/Camera3D/InteractRay
@onready var flashlight_light: SpotLight3D = $Head/Camera3D/Flashlight
@onready var prompt_label: Label = get_tree().current_scene.get_node_or_null("CanvasLayer/PromptLabel")
@onready var battery_label: Label = get_tree().current_scene.get_node_or_null("CanvasLayer/BatteryLabel")
@onready var message_label: Label = get_tree().current_scene.get_node_or_null("CanvasLayer/MessageLabel")
@onready var stamina_bar: ProgressBar = get_tree().current_scene.get_node_or_null("CanvasLayer/StaminaBar")

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

	if flashlight_light:
		flashlight_light.visible = false
	else:
		push_warning("Flashlight (SpotLight3D) not found - ตรวจชื่อ node ว่าเป็น Flashlight")

	if interact_ray == null:
		push_warning("InteractRay not found - ตรวจ path ของ interact_ray")

# ---------- State ----------
func _ui_open() -> bool:
	var ui = get_tree().get_first_node_in_group("notebook_ui")
	return ui != null and ui.visible

func _can_control() -> bool:
	return not _ui_open() and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

# ---------- Input ----------
func _unhandled_input(event: InputEvent) -> void:
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
	if flashlight_on:
		battery -= BATTERY_DRAIN_PER_SEC * delta
		if battery <= 0.0:
			battery = 0.0
			_set_flashlight(false)
		_update_battery_label()

# ---------- Movement ----------
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var can_control := _can_control()

	var input_dir := Vector2.ZERO
	if can_control:
		input_dir = Input.get_vector("move-left", "move-right", "move-forward", "move-backward")

	# --- จัดการเรื่องความเร็ว (Sprint / Crouch / Walk) ---
	var is_crouching := false
	var wants_sprint := false

	if can_control:
		is_crouching = Input.is_action_pressed("crouch")
		wants_sprint = Input.is_action_pressed("sprint") and not is_crouching

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

	# ตำแหน่งเป้าหมายความสูงของ Head (แยกตามสถานะ ย่อ/เดินปกติ)
	var target_y = head_crouch_y if is_crouching else head_start_y

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

	if _ui_open():
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

	global_position = start_position
	var up_motion := Vector3.UP * MAX_STEP_HEIGHT
	var up_collision := KinematicCollision3D.new()
	if test_move(global_transform, up_motion, up_collision):
		up_motion = up_collision.get_travel()
	global_position += up_motion

	var forward_motion := Vector3(start_velocity.x, 0, start_velocity.z) * delta
	if test_move(global_transform, forward_motion):
		global_position = end_position
		return
	global_position += forward_motion

	var down_collision := KinematicCollision3D.new()
	if test_move(global_transform, Vector3.DOWN * (up_motion.y + 0.05), down_collision):
		if down_collision.get_normal().angle_to(Vector3.UP) <= floor_max_angle:
			global_position += down_collision.get_travel()
			return

	global_position = end_position

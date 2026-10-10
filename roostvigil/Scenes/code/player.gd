extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003
const MAX_STEP_HEIGHT = 0.4

# Head bob
const BOB_FREQ = 2.0
const BOB_AMP = 0.06
const BOB_HORIZONTAL = 0.03
var bob_time := 0.0
var head_start_y := 0.0

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var interact_ray: RayCast3D = $Head/Camera3D/InteractRay
@onready var prompt_label: Label = get_tree().current_scene.get_node_or_null("CanvasLayer/PromptLabel")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	head_start_y = head.position.y

	if prompt_label:
		prompt_label.visible = false
	else:
		push_warning("PromptLabel not found - ตรวจ path ของ prompt_label")

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
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

	if event.is_action_pressed("Interact"):
		_try_interact()

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# ---------- Movement ----------
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var can_control := _can_control()

	if can_control and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Vector2.ZERO
	if can_control:
		input_dir = Input.get_vector("move-left", "move-right", "move-forward", "move-backward")

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0
		velocity.z = 0

	var was_on_floor := is_on_floor()
	var start_position := global_position
	var start_velocity := velocity

	move_and_slide()

	if was_on_floor and is_on_wall() and direction != Vector3.ZERO and velocity.y <= 0.0:
		_try_step_up(start_position, start_velocity, delta)

	_update_head_bob(delta)
	_update_prompt()

# ---------- Head Bob ----------
func _update_head_bob(delta: float) -> void:
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	if is_on_floor() and horizontal_speed > 0.1:
		bob_time += delta * horizontal_speed
		var target := Vector3(
			cos(bob_time * BOB_FREQ * 0.5) * BOB_HORIZONTAL,
			head_start_y + sin(bob_time * BOB_FREQ) * BOB_AMP,
			0.0
		)
		head.position = head.position.lerp(target, delta * 15.0)
	else:
		var rest := Vector3(0.0, head_start_y, 0.0)
		head.position = head.position.lerp(rest, delta * 8.0)

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

	# ซ่อน prompt ตอน UI เปิดอยู่
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

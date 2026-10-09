extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003
const MAX_STEP_HEIGHT = 0.4

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move-left", "move-right", "move-forward", "move-backward")
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

	# ถ้าชนกำแพงขณะอยู่บนพื้น ลอง step-up
	if was_on_floor and is_on_wall() and direction != Vector3.ZERO and velocity.y <= 0.0:
		_try_step_up(start_position, start_velocity, delta)

func _try_step_up(start_position: Vector3, start_velocity: Vector3, delta: float) -> void:
	var end_position := global_position

	# 1) กลับไปจุดเริ่ม แล้วยกขึ้นเท่าความสูงขั้นสูงสุด
	global_position = start_position
	var up_motion := Vector3.UP * MAX_STEP_HEIGHT
	var up_collision := KinematicCollision3D.new()
	if test_move(global_transform, up_motion, up_collision):
		# เพดานชนหัว ยกไม่ได้เต็มที่ ใช้เท่าที่ยกได้
		up_motion = up_collision.get_travel()
	global_position += up_motion

	# 2) เดินไปข้างหน้าที่ระดับสูงขึ้น
	var forward_motion := Vector3(start_velocity.x, 0, start_velocity.z) * delta
	if test_move(global_transform, forward_motion):
		# ยังชนอยู่ แปลว่าสูงเกินไป ยกเลิก
		global_position = end_position
		return
	global_position += forward_motion

	# 3) กดลงมาเกาะพื้น
	var down_collision := KinematicCollision3D.new()
	if test_move(global_transform, Vector3.DOWN * (up_motion.y + 0.05), down_collision):
		var floor_normal := down_collision.get_normal()
		# ต้องเป็นพื้นราบพอที่จะยืนได้
		if floor_normal.angle_to(Vector3.UP) <= floor_max_angle:
			global_position += down_collision.get_travel()
			return

	# ถ้าไม่เจอพื้นที่ยืนได้ ยกเลิก กลับตำแหน่งเดิมหลัง move_and_slide
	global_position = end_position

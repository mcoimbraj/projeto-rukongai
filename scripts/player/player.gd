extends CharacterBody3D

@export var speed := 5.0
@export var mouse_sensitivity := 0.002
@export var mobile_sensitivity := 3.0
@export var tilt_strength := 10.0

var rotation_x := 0.0

func _ready():
	if not OS.has_feature("mobile"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	$Camera3D.current = true


# =========================
# CONTROLE DE CÂMERA (PC)
# =========================
func _input(event):
	if OS.has_feature("mobile"):
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)

		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, -1.5, 1.5)
		$Camera3D.rotation.x = rotation_x


# =========================
# MOVIMENTO
# =========================
func _physics_process(delta):
	if OS.has_feature("mobile"):
		handle_mobile(delta)
	else:
		handle_pc(delta)

	move_and_slide()


# =========================
# PC (WASD)
# =========================
func handle_pc(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed


# =========================
# MOBILE (SENSORES)
# =========================
func handle_mobile(delta):
	var accel = Input.get_accelerometer()
	var gyro = Input.get_gyroscope()

	# 🔥 DEBUG: se estiver no PC, simula input
	if accel == Vector3.ZERO:
		accel.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		accel.y = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")

	if gyro == Vector3.ZERO:
		gyro.y = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		gyro.x = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")

	# 🔄 ROTAÇÃO
	rotate_y(-gyro.y * mobile_sensitivity)

	rotation_x -= gyro.x * mobile_sensitivity
	rotation_x = clamp(rotation_x, -1.2, 1.2)
	$Camera3D.rotation.x = rotation_x

	# 🚶 MOVIMENTO
	var forward = -transform.basis.z
	var right = transform.basis.x

	var direction = Vector3.ZERO
	direction += forward * accel.y * tilt_strength
	direction += right * accel.x * tilt_strength

	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

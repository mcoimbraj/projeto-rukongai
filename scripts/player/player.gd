extends CharacterBody3D

# =========================
# CONFIG
# =========================
@export var speed := 6.0
@export var mouse_sensitivity := 0.002
@export var mobile_sensitivity := 3.0

# Step system
@export var step_threshold := 1.2
@export var step_cooldown := 0.3
@export var step_force := 8.0
@export var friction := 10.0

# =========================
# VARIÁVEIS
# =========================
var rotation_x := 0.0

# Step detection
var last_step_time := 0.0
var prev_magnitude := 0.0

# =========================
# READY
# =========================
func _ready():
	if OS.get_name() != "Android":
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	$Camera3D.current = true


# =========================
# INPUT (PC)
# =========================
func _input(event):
	if OS.get_name() == "Android":
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)

		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, -1.5, 1.5)
		$Camera3D.rotation.x = rotation_x


# =========================
# LOOP PRINCIPAL
# =========================
func _physics_process(delta):
	if OS.get_name() == "Android":
		handle_mobile(delta)
	else:
		handle_pc(delta)

	# freio natural (evita "sabão")
	velocity = velocity.move_toward(Vector3.ZERO, friction * delta)

	move_and_slide()


# =========================
# PC MOVEMENT
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

	if direction != Vector3.ZERO:
		velocity = direction * speed


# =========================
# MOBILE (PASSOS REAIS)
# =========================
func handle_mobile(delta):
	var accel = Input.get_accelerometer()
	var gyro = Input.get_gyroscope()

	# =========================
	# ROTAÇÃO (GIROSCÓPIO)
	# =========================
	rotate_y(-gyro.y * mobile_sensitivity)

	rotation_x -= gyro.x * mobile_sensitivity
	rotation_x = clamp(rotation_x, -1.2, 1.2)
	$Camera3D.rotation.x = rotation_x

	# =========================
	# DETECTA PASSO
	# =========================
	if detect_step(accel):
		move_step()


# =========================
# DETECÇÃO DE PASSO
# =========================
func detect_step(accel: Vector3) -> bool:
	var magnitude = accel.length()

	var delta = magnitude - prev_magnitude
	prev_magnitude = magnitude

	var now = Time.get_ticks_msec() / 1000.0

	# Detecta pico
	if delta > step_threshold and (now - last_step_time) > step_cooldown:
		last_step_time = now
		return true

	return false


# =========================
# MOVIMENTO POR PASSO
# =========================
func move_step():
	var forward = -transform.basis.z

	# impulso de movimento
	velocity = forward * step_force
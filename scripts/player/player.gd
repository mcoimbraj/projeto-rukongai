extends CharacterBody3D

# =========================
# CONFIG
# =========================
@export var speed := 6.0
@export var mouse_sensitivity := 0.002
@export var mobile_sensitivity := 2.0

# Step system
@export var step_threshold := 2.5   # 🔥 ajuste para calibrar a sensibilidade do passo (depende do dispositivo)
@export var step_cooldown := 0.4
@export var step_force := 6.0
@export var friction := 12.0

# Sensor filtering
@export var accel_smoothing := 0.1
@export var gyro_smoothing := 0.1
@export var deadzone := 0.15   # 🔥 ajuste para ignorar ruídos pequenos (depende do dispositivo)

# =========================
# VARIÁVEIS
# =========================
var rotation_x := 0.0

var last_step_time := 0.0
var prev_magnitude := 0.0

# sensores filtrados
var smooth_accel := Vector3.ZERO
var smooth_gyro := Vector3.ZERO

# =========================
# READY
# =========================
func _ready():
	if OS.get_name() != "Android":
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	$Camera3D.current = true


# =========================
# LOOP
# =========================
func _physics_process(delta):
	if OS.get_name() == "Android":
		handle_mobile(delta)
	else:
		handle_pc(delta)

	# freio natural
	velocity = velocity.move_toward(Vector3.ZERO, friction * delta)

	move_and_slide()


# =========================
# PC
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

	if direction != Vector3.ZERO:
		velocity = direction.normalized() * speed


# =========================
# MOBILE
# =========================
func handle_mobile(delta):
	var raw_accel = Input.get_accelerometer()
	var raw_gyro = Input.get_gyroscope()

	# =========================
	# FILTRO (LOW PASS)
	# =========================
	smooth_accel = smooth_accel.lerp(raw_accel, accel_smoothing)
	smooth_gyro = smooth_gyro.lerp(raw_gyro, gyro_smoothing)

	# =========================
	# DEADZONE
	# =========================
	if abs(smooth_gyro.x) < deadzone:
		smooth_gyro.x = 0
	if abs(smooth_gyro.y) < deadzone:
		smooth_gyro.y = 0

	# =========================
	# ROTAÇÃO (CONTROLADA)
	# =========================
	if smooth_gyro.length() > 0:
		rotate_y(-smooth_gyro.y * mobile_sensitivity)

		rotation_x -= smooth_gyro.x * mobile_sensitivity
		rotation_x = clamp(rotation_x, -1.2, 1.2)
		$Camera3D.rotation.x = rotation_x

	# =========================
	# PASSO REAL
	# =========================
	if detect_step(smooth_accel):
		move_step()


# =========================
# DETECÇÃO DE PASSO (ROBUSTA)
# =========================
func detect_step(accel: Vector3) -> bool:
	var magnitude = accel.length()

	var delta = magnitude - prev_magnitude
	prev_magnitude = magnitude

	var now = Time.get_ticks_msec() / 1000.0

	# 🔥 ignora micro variações
	if abs(delta) < 0.2:
		return false

	# 🔥 detecta pico real
	if delta > step_threshold and (now - last_step_time) > step_cooldown:
		last_step_time = now
		print("👣 PASSO DETECTADO")
		return true

	return false


# =========================
# MOVIMENTO POR PASSO
# =========================
func move_step():
	var forward = -transform.basis.z

	velocity = forward * step_force
extends CharacterBody3D

# =========================
# CONFIG
# =========================
@export var speed := 6.0
@export var mouse_sensitivity := 0.002

# Mobile
@export var mobile_sensitivity := 2.0
@export var vertical_sensitivity := 1.0
@export var camera_smooth := 8.0
@export var max_look_speed := 2.0

# Step system
@export var step_threshold := 2.5
@export var step_cooldown := 0.4
@export var step_force := 6.0
@export var friction := 12.0

# Sensor filtering
@export var accel_smoothing := 0.1
@export var gyro_smoothing := 0.1
@export var deadzone := 0.2

# =========================
# VARIÁVEIS
# =========================
var rotation_x := 0.0
var target_rotation_x := 0.0

# Step
var last_step_time := 0.0
var prev_magnitude := 0.0

# Sensor smoothing
var smooth_accel := Vector3.ZERO
var smooth_gyro := Vector3.ZERO

# Calibração
var base_accel := Vector3.ZERO
var calibrated := false


# =========================
# READY
# =========================
func _ready():
	if OS.get_name() != "Android":
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	$Camera3D.current = true


# =========================
# INPUT PC
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
# LOOP
# =========================
func _physics_process(delta):
	if OS.get_name() == "Android":
		handle_mobile(delta)
	else:
		handle_pc(delta)

	# freio
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
	# CALIBRAÇÃO AUTOMÁTICA
	# =========================
	if not calibrated:
		base_accel = raw_accel
		calibrated = true

	raw_accel -= base_accel

	# =========================
	# FILTRO
	# =========================
	smooth_accel = smooth_accel.lerp(raw_accel, accel_smoothing)
	smooth_gyro = smooth_gyro.lerp(raw_gyro, gyro_smoothing)

	# =========================
	# DEADZONE
	# =========================
	smooth_gyro.x = apply_deadzone(smooth_gyro.x)
	smooth_gyro.y = apply_deadzone(smooth_gyro.y)

	# =========================
	# ROTAÇÃO (ESTÁVEL)
	# =========================
	var gyro_x = clamp(smooth_gyro.x, -max_look_speed, max_look_speed)
	var gyro_y = clamp(smooth_gyro.y, -max_look_speed, max_look_speed)

	# horizontal
	if abs(gyro_y) > 0:
		rotate_y(-gyro_y * mobile_sensitivity)

	# vertical (suavizado)
	if abs(gyro_x) > 0:
		target_rotation_x -= gyro_x * vertical_sensitivity
		target_rotation_x = clamp(target_rotation_x, -1.2, 1.2)

	rotation_x = lerp(rotation_x, target_rotation_x, camera_smooth * delta)
	$Camera3D.rotation.x = rotation_x

	# =========================
	# PASSO
	# =========================
	if detect_step(smooth_accel):
		move_step()


# =========================
# DEADZONE
# =========================
func apply_deadzone(value: float) -> float:
	if abs(value) < deadzone:
		return 0.0
	return value


# =========================
# DETECTAR PASSO
# =========================
func detect_step(accel: Vector3) -> bool:
	var magnitude = accel.length()

	var delta = magnitude - prev_magnitude
	prev_magnitude = magnitude

	var now = Time.get_ticks_msec() / 1000.0

	# ignora ruído pequeno
	if abs(delta) < 0.3:
		return false

	if delta > step_threshold and (now - last_step_time) > step_cooldown:
		last_step_time = now
		print("👣 PASSO")
		return true

	return false


# =========================
# MOVIMENTO POR PASSO
# =========================
func move_step():
	var forward = -transform.basis.z
	velocity = forward * step_force


# =========================
# 🔥 FUNÇÃO EXTRA IMPORTANTE
# =========================
func recalibrate_sensors():
	print("📱 Recalibrando sensores...")
	calibrated = false
	smooth_accel = Vector3.ZERO
	smooth_gyro = Vector3.ZERO
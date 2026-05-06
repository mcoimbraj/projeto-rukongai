extends CharacterBody3D

# =========================
# CONFIG
# =========================
@export var speed := 6.0
@export var mouse_sensitivity := 0.002

# Mobile camera
@export var mobile_sensitivity := 1.8
@export var vertical_sensitivity := 0.5
@export var camera_smooth := 7.0
@export var max_look_speed := 1.2

# Movement
@export var step_force := 9.0
@export var friction := 25.0
@export var tilt_force := 0.8  

# Step detection (REAL)
@export var step_peak := 11
@export var step_cooldown := 0.55

# Sensor filtering
@export var accel_smoothing := 0.08
@export var gyro_smoothing := 0.15
@export var deadzone := 0.08

# =========================
# VARIÁVEIS
# =========================
var rotation_x := 0.0
var target_rotation_x := 0.0

var last_step_time := 0.0

var smooth_accel := Vector3.ZERO
var smooth_gyro := Vector3.ZERO

# Gravidade estimada
var gravity_est := Vector3.ZERO
const GRAVITY_ALPHA := 0.9

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

	# Freio
	velocity = velocity.move_toward(Vector3.ZERO, friction * delta)

	move_and_slide()

# =========================
# PC
# =========================
func handle_pc(_delta):
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
	# GRAVIDADE DINÂMICA
	# =========================
	gravity_est = gravity_est.lerp(raw_accel, 1.0 - GRAVITY_ALPHA)
	var linear_accel = raw_accel - gravity_est

	# =========================
	# FILTROS (apenas para movimento suave)
	# =========================
	smooth_accel = smooth_accel.lerp(linear_accel, accel_smoothing)
	smooth_gyro = smooth_gyro.lerp(raw_gyro, gyro_smoothing)

	# =========================
	# DEADZONE
	# =========================
	smooth_gyro.x = apply_deadzone(smooth_gyro.x)
	smooth_gyro.y = apply_deadzone(smooth_gyro.y)

	# =========================
	# LIMITES
	# =========================
	var gyro_x = clamp(smooth_gyro.x, -max_look_speed, max_look_speed)
	var gyro_y = clamp(smooth_gyro.y, -max_look_speed, max_look_speed)

	# =========================
	# CURVA DE RESPOSTA
	# =========================
	var response_x = pow(abs(gyro_x), 1.5) * sign(gyro_x)
	var response_y = pow(abs(gyro_y), 1.5) * sign(gyro_y)

	# =========================
	# ROTAÇÃO
	# =========================
	if abs(response_y) > 0.05:
		rotate_y(response_y * mobile_sensitivity * delta)

	if abs(response_x) > 0.05:
		target_rotation_x -= response_x * vertical_sensitivity * delta
		target_rotation_x = clamp(target_rotation_x, -1.2, 1.2)

	rotation_x = lerp(rotation_x, target_rotation_x, camera_smooth * delta)
	$Camera3D.rotation.x = rotation_x

	# =========================
	# MOVIMENTO CONTÍNUO (inclinação)
	# =========================
	var tilt = smooth_accel.x  # eixo pode variar dependendo do aparelho

	if abs(tilt) > 0.05:
		var forward = -transform.basis.z
		velocity += forward * tilt * tilt_force

	# =========================
	# PASSO REAL (acelerômetro cru)
	# =========================
	if detect_step_raw(raw_accel):
		move_step()

# =========================
# DETECTAR PASSO REAL
# =========================
func detect_step_raw(raw_accel: Vector3) -> bool:
	var magnitude = raw_accel.length()
	var now = Time.get_ticks_msec() / 1000.0

	if magnitude > step_peak and (now - last_step_time) > step_cooldown:
		last_step_time = now
		print("👣 PASSO REAL:", magnitude)
		return true

	return false

# =========================
# MOVIMENTO POR PASSO
# =========================
func move_step():
	var forward = -transform.basis.z
	velocity += forward * step_force

# =========================
# DEADZONE
# =========================
func apply_deadzone(value: float) -> float:
	if abs(value) < deadzone:
		return 0.0
	return value

# =========================
# RECALIBRAR
# =========================
func recalibrate_sensors():
	print("📱 Recalibrando sensores...")
	gravity_est = Input.get_accelerometer()
	smooth_accel = Vector3.ZERO
	smooth_gyro = Vector3.ZERO
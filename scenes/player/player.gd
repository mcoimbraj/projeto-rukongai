extends CharacterBody3D

# =========================
# CONFIGURAÇÃO
# =========================

@export var speed := 4.0
@export var mouse_sensitivity := 0.002

# Mobile camera
@export var mobile_sensitivity := 1.8
@export var vertical_sensitivity := 0.5
@export var camera_smooth := 7.0
@export var max_look_speed := 1.2

# Movement
@export var step_force := 6.0
@export var friction := 18.0
@export var base_speed := 1.8

# Step detection
@export var step_peak := 9.5
@export var step_cooldown := 0.45

# Sensor filtering
@export var accel_smoothing := 0.08
@export var gyro_smoothing := 0.15
@export var deadzone := 0.04

# =========================
# VARIÁVEIS
# =========================

var rotation_x := 0.0
var target_rotation_x := 0.0

var last_step_time := 0.0
var last_magnitude := 0.0
var rising := false

var smooth_accel := Vector3.ZERO
var smooth_gyro := Vector3.ZERO

# Gravidade estimada
var gravity_est := Vector3.ZERO
const GRAVITY_ALPHA := 0.8

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

	# aplica atrito
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
	# FILTROS
	# =========================
	smooth_accel = smooth_accel.lerp(linear_accel, accel_smoothing)
	smooth_gyro = smooth_gyro.lerp(raw_gyro, gyro_smoothing)

	# =========================
	# DEADZONE
	# =========================
	smooth_gyro.x = apply_deadzone(smooth_gyro.x)
	smooth_gyro.y = apply_deadzone(smooth_gyro.y)

	# =========================
	# CAMERA (GIROSCÓPIO)
	# =========================
	var gyro_x = clamp(smooth_gyro.x, -max_look_speed, max_look_speed)
	var gyro_y = clamp(smooth_gyro.y, -max_look_speed, max_look_speed)

	var response_x = pow(abs(gyro_x), 1.5) * sign(gyro_x)
	var response_y = pow(abs(gyro_y), 1.5) * sign(gyro_y)

	if abs(response_y) > 0.05:
		rotate_y(response_y * mobile_sensitivity * delta)

	if abs(response_x) > 0.05:
		target_rotation_x -= response_x * vertical_sensitivity * delta
		target_rotation_x = clamp(target_rotation_x, -1.2, 1.2)

	rotation_x = lerp(rotation_x, target_rotation_x, camera_smooth * delta)
	$Camera3D.rotation.x = rotation_x

	# =========================
	# MOVIMENTO BASE (sempre leve)
	# =========================
	var forward = -transform.basis.z
	velocity += forward * base_speed * delta

	# =========================
	# MOVIMENTO POR ACELERAÇÃO REAL (andar/correr)
	# =========================
	var forward_motion = smooth_accel.z

	if abs(forward_motion) > 0.03:
		velocity += forward * forward_motion * 4.0

	# =========================
	# PASSOS REAIS
	# =========================
	if detect_step(linear_accel):
		move_step()

# =========================
# DETECÇÃO DE PASSO REAL (pico + queda)
# =========================
func detect_step(accel: Vector3) -> bool:
	var magnitude = accel.length()
	var now = Time.get_ticks_msec() / 1000.0

	var detected := false

	if magnitude > last_magnitude:
		rising = true
	elif rising and magnitude < last_magnitude:
		# pico detectado
		if last_magnitude > step_peak and (now - last_step_time) > step_cooldown:
			last_step_time = now
			detected = true
			print("👣 PASSO:", last_magnitude)

		rising = false

	last_magnitude = magnitude
	return detected

# =========================
# MOVIMENTO POR PASSO
# =========================
func move_step():
	var forward = -transform.basis.z

	var strength = clamp(last_magnitude / step_peak, 0.8, 1.5)
	velocity += forward * step_force * strength

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
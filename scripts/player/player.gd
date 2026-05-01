extends CharacterBody3D

# =========================
# CONFIG
# =========================
@export var speed := 6.0
@export var mouse_sensitivity := 0.002

# Mobile (AJUSTADO)
@export var mobile_sensitivity := 1.5
@export var vertical_sensitivity := 0.45
@export var camera_smooth := 6.0
@export var max_look_speed := 1.0

# Step system 
@export var step_threshold := 1.2
@export var step_cooldown := 0.4
@export var step_force := 8.0
@export var friction := 12.0

# Sensor filtering
@export var accel_smoothing := 0.2
@export var gyro_smoothing := 0.15
@export var deadzone := 0.15

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

# --- CORREÇÃO: gravidade estimada dinamicamente ---
var gravity_est := Vector3.ZERO
const GRAVITY_ALPHA := 0.9   # passa‑baixa, 0.9 = reage rápido

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

	# freio natural
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
# MOBILE (CORRIGIDO)
# =========================
func handle_mobile(delta):
	var raw_accel = Input.get_accelerometer()
	var raw_gyro = Input.get_gyroscope()

	# =========================
	# GRAVIDADE DINÂMICA (substitui a calibração antiga)
	# =========================
	gravity_est = gravity_est.lerp(raw_accel, 1.0 - GRAVITY_ALPHA)
	var linear_accel = raw_accel - gravity_est   # aceleração real do movimento

	# =========================
	# FILTRO (aceleração linear)
	# =========================
	smooth_accel = smooth_accel.lerp(linear_accel, accel_smoothing)

	# Giroscópio (velocidade angular)
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
	# ROTAÇÃO HORIZONTAL (🔥 multiplicado por delta)
	# =========================
	if abs(response_y) > 0.05:
		rotate_y(response_y * mobile_sensitivity * delta)

	# =========================
	# ROTAÇÃO VERTICAL (🔥 multiplicado por delta)
	# =========================
	if abs(response_x) > 0.07:
		target_rotation_x -= response_x * vertical_sensitivity * delta
		target_rotation_x = clamp(target_rotation_x, -1.2, 1.2)

	rotation_x = lerp(rotation_x, target_rotation_x, camera_smooth * delta)
	$Camera3D.rotation.x = rotation_x

	# =========================
	# PASSO (usando aceleração linear suavizada)
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
	
	# Ignora acelerações muito fracas
	if magnitude < 0.6:   # ligeiramente menor que a original (0.8)
		return false
	
	var delta = magnitude - prev_magnitude
	prev_magnitude = magnitude
	
	var now = Time.get_ticks_msec() / 1000.0
	
	# DEBUG: monitore os picos
	if delta > 1.0:
		print("Delta: ", delta)
	
	# Apenas importa se o delta for grande o suficiente e o cooldown permitir
	if delta > step_threshold and (now - last_step_time) > step_cooldown:
		last_step_time = now
		print("👣 PASSO (delta: ", delta, ")")
		return true
	
	return false
# =========================
# MOVIMENTO POR PASSO
# =========================
func move_step():
	var forward = -transform.basis.z
	velocity += forward * step_force

# =========================
# RECALIBRAR (agora reseta a estimativa da gravidade)
# =========================
func recalibrate_sensors():
	print("📱 Resetando estimativa da gravidade...")
	gravity_est = Input.get_accelerometer()   # reinicia com leitura atual
	smooth_accel = Vector3.ZERO
	smooth_gyro = Vector3.ZERO

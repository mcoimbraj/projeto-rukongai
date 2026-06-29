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
# CORREÇÃO: aumentado de 11 para 14 para evitar falsos positivos
# O acelerômetro em repouso já lê ~9.8 (gravidade), então 11 é muito sensível
@export var step_peak := 14.0
@export var step_cooldown := 0.55

# Sensor filtering
@export var accel_smoothing := 0.08
# CORREÇÃO: alpha de gravidade mais alto = convergência mais rápida
# Antes: 0.9 resultava em lerp com fator 0.1 (muito lento)
@export var gyro_smoothing := 0.15
@export var deadzone := 0.08

# Gravidade do mundo (Godot usa -9.8 no eixo Y por padrão)
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# =========================
# VARIÁVEIS
# =========================
var rotation_x := 0.0
var target_rotation_x := 0.0

var last_step_time := 0.0

var smooth_accel := Vector3.ZERO
var smooth_gyro := Vector3.ZERO

# Gravidade estimada do sensor
var gravity_est := Vector3.ZERO
# CORREÇÃO: alpha mais alto = sensor aprende orientação mais rápido
const GRAVITY_ALPHA := 0.98

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
	# CORREÇÃO: aplica gravidade do mundo antes de tudo
	# Isso garante que o personagem caia quando não está no chão
	if not is_on_floor():
		velocity.y -= gravity * delta

	if OS.get_name() == "Android":
		handle_mobile(delta)
	else:
		handle_pc(delta)

	# CORREÇÃO: fricção apenas nos eixos horizontais (X e Z)
	# Antes, o move_toward zerava velocity.y também, brigando com a gravidade
	var horizontal := Vector2(velocity.x, velocity.z)
	horizontal = horizontal.move_toward(Vector2.ZERO, friction * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.y
	# velocity.y NÃO é frenada aqui — gravidade e chão cuidam disso

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
		# Garante que o movimento horizontal não afete Y
		var move = direction.normalized()
		velocity.x = move.x * speed
		velocity.z = move.z * speed

# =========================
# MOBILE
# =========================
func handle_mobile(delta):
	var raw_accel = Input.get_accelerometer()
	var raw_gyro = Input.get_gyroscope()

	# =========================
	# GRAVIDADE DINÂMICA
	# CORREÇÃO: alpha mais alto (0.98) = converge mais rápido para a
	# orientação real do aparelho, reduzindo "gravidade residual" em linear_accel
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
	# PASSO REAL (acelerômetro cru)
	# CORREÇÃO: só aplica passo OU inclinação por frame, nunca os dois
	# para evitar impulsos duplos que lançam o personagem
	# =========================
	if detect_step_raw(raw_accel):
		move_step()
	else:
		# Movimento por inclinação só ocorre se NÃO foi detectado passo
		apply_tilt(delta)

# =========================
# INCLINAÇÃO (separada para evitar conflito com passo)
# =========================
func apply_tilt(_delta):
	# NOTA: o eixo da inclinação pode variar por aparelho.
	# Se o personagem andar para os lados em vez de frente/trás,
	# troque smooth_accel.x por smooth_accel.y
	var tilt = smooth_accel.x

	if abs(tilt) > 0.05:
		var forward = -transform.basis.z
		velocity.x += forward.x * tilt * tilt_force
		velocity.z += forward.z * tilt * tilt_force
		# Não afeta Y — gravidade é separada

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
	velocity.x += forward.x * step_force
	velocity.z += forward.z * step_force
	# Não afeta Y — evita que o personagem "pule" ao dar um passo

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
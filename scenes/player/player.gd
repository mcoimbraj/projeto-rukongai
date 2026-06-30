extends CharacterBody3D

# =========================
# CONFIG
# =========================
@export var speed := 6.0
@export var mouse_sensitivity := 0.002

# Giroscópio — câmera
@export var gyro_sensitivity_h := 1.5   # horizontal (rotação do corpo)
@export var gyro_sensitivity_v := 1.0   # vertical (câmera)
@export var gyro_smoothing := 0.2
@export var gyro_deadzone := 0.05
@export var camera_smooth := 10.0

# Detecção de passo
# Usa get_linear_acceleration() — já vem sem gravidade (filtrado pelo SO)
# Um passo real gera pico de ~2.5–5 m/s². Ajuste se detectar pouco ou demais.
@export var step_threshold := 2.5
@export var step_cooldown := 0.45       # mínimo de segundos entre passos
@export var step_force := 8.0           # impulso por passo

# Fricção — freia o personagem entre passos
@export var friction := 14.0

# Gravidade do mundo
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# =========================
# VARIÁVEIS INTERNAS
# =========================
var cam_pitch := 0.0          # rotação vertical da câmera (eixo X)
var smooth_gyro := Vector3.ZERO
var last_step_time := 0.0

# =========================
# READY
# =========================
func _ready():
	if OS.get_name() == "Android":
		# Nada a capturar — input é por sensor
		pass
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	$Camera3D.current = true

# =========================
# INPUT — só mouse no PC
# =========================
func _input(event):
	if OS.get_name() == "Android":
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		cam_pitch -= event.relative.y * mouse_sensitivity
		cam_pitch = clamp(cam_pitch, -1.4, 1.4)
		$Camera3D.rotation.x = cam_pitch

# =========================
# LOOP PRINCIPAL
# =========================
func _physics_process(delta):
	# Gravidade do mundo — sempre, em todo dispositivo
	if not is_on_floor():
		velocity.y -= gravity * delta

	if OS.get_name() == "Android":
		_handle_gyro(delta)
		_handle_step()
	else:
		_handle_pc(_delta = delta)

	# Fricção só horizontal — Y é responsabilidade da gravidade
	velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	velocity.z = move_toward(velocity.z, 0.0, friction * delta)

	move_and_slide()

# =========================
# PC — teclado/mouse
# =========================
func _handle_pc(_delta):
	var dir := Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		dir -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		dir += transform.basis.z
	if Input.is_action_pressed("move_left"):
		dir -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		dir += transform.basis.x

	if dir != Vector3.ZERO:
		var move := dir.normalized()
		velocity.x = move.x * speed
		velocity.z = move.z * speed

# =========================
# GIROSCÓPIO — câmera e direção
# Giroscópio mede velocidade angular (rad/s) — perfeito para câmera,
# sem deriva e sem gravidade misturada.
# =========================
func _handle_gyro(delta):
	var raw := Input.get_gyroscope()

	# Suavização leve para tirar tremor de mão
	smooth_gyro = smooth_gyro.lerp(raw, gyro_smoothing)

	# Deadzone
	var gx := _deadzone(smooth_gyro.x)   # inclina para cima/baixo
	var gy := _deadzone(smooth_gyro.y)   # gira para os lados

	# Rotação horizontal — gira o corpo inteiro do CharacterBody3D
	# O personagem sempre anda para onde está olhando
	rotate_y(-gy * gyro_sensitivity_h * delta)

	# Rotação vertical — só a câmera
	cam_pitch -= gx * gyro_sensitivity_v * delta
	cam_pitch = clamp(cam_pitch, -1.4, 1.4)   # ~80° para cima e para baixo
	$Camera3D.rotation.x = cam_pitch

# =========================
# PASSO — detecção e impulso
# get_linear_acceleration() já desconta a gravidade (sensor fusion do SO).
# Diferente do acelerômetro bruto, aqui um passo real gera ~2.5–5 m/s²,
# não ~11+ misturado com 9.8 de gravidade.
# =========================
func _handle_step():
	var linear := Input.get_linear_acceleration()
	var magnitude := linear.length()
	var now := Time.get_ticks_msec() / 1000.0

	if magnitude > step_threshold and (now - last_step_time) > step_cooldown:
		last_step_time = now
		print("👣 passo:", snappedf(magnitude, 0.01))
		_move_step()

func _move_step():
	# Avança na direção horizontal que o personagem está olhando.
	# -transform.basis.z é o "para frente" do CharacterBody3D.
	# Zeramos Y para o passo nunca lançar o personagem para cima.
	var forward := -transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()

	velocity.x += forward.x * step_force
	velocity.z += forward.z * step_force

# =========================
# UTILIDADE
# =========================
func _deadzone(value: float) -> float:
	if abs(value) < gyro_deadzone:
		return 0.0
	return value	
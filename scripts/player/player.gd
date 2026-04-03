extends CharacterBody3D

@export var speed := 5.0
@export var mouse_sensitivity := 0.002

var rotation_x := 0.0

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
    if event is InputEventMouseMotion:
        # Rotação horizontal (corpo)
        rotate_y(-event.relative.x * mouse_sensitivity)

        # Rotação vertical (câmera)
        rotation_x -= event.relative.y * mouse_sensitivity
        rotation_x = clamp(rotation_x, -1.5, 1.5)
        $Camera3D.rotation.x = rotation_x


func _physics_process(delta):
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

    move_and_slide()
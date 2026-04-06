extends Node3D

@export var ghost_scene: PackedScene
@export var spawn_count := 5
@export var spawn_area := Vector3(20, 0, 20)

func _ready():
	print("Spawner rodando")
	spawn_ghosts()

func spawn_ghosts():
	for i in spawn_count:
		var ghost = ghost_scene.instantiate()

		var random_pos = Vector3(
			randf_range(-spawn_area.x, spawn_area.x),
			1,
			randf_range(-spawn_area.z, spawn_area.z)
		)

		ghost.position = random_pos
		add_child(ghost)

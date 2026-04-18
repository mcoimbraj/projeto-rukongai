extends Node3D

# 🔥 Cena do ghost (defina no Inspector OU use preload)
@export var ghost_scene: PackedScene

# 🔥 Número fixo de fantasmas por rodada
@export var spawn_count := 3

# 🔥 Limites do mapa (ajuste conforme seu chão)
@export var map_min := Vector3(-20, 0, -20)
@export var map_max := Vector3(20, 0, 20)

# 🔥 Distância mínima entre fantasmas (evita sobreposição)
@export var min_distance := 5.0

var spawned_positions: Array = []

func _ready():
	randomize()
	print("Spawner rodando")
	spawn_ghosts()

func spawn_ghosts():
	if ghost_scene == null:
		print("ERRO: ghost_scene está NULL")
		return

	spawned_positions.clear()

	for i in spawn_count:
		var ghost = ghost_scene.instantiate()

		var pos = get_valid_position()
		ghost.position = pos

		add_child(ghost)

		# 🔥 Aqui pegamos o Youkai do ghost
		if ghost.has_variable("youkai_data") and ghost.youkai_data != null:
			print("👻 Ghost spawnado:", ghost.youkai_data.name, "em", pos)
		else:
			print("👻 Ghost spawnado sem Youkai em", pos)


# =========================
# POSIÇÃO ALEATÓRIA VÁLIDA
# =========================
func get_valid_position() -> Vector3:
	var attempts := 0

	while attempts < 20:
		var pos = Vector3(
			randf_range(map_min.x, map_max.x),
			1,
			randf_range(map_min.z, map_max.z)
		)

		if is_position_valid(pos):
			spawned_positions.append(pos)
			return pos

		attempts += 1

	# fallback (se falhar muito)
	print("⚠ Falha ao achar posição ideal, usando fallback")
	return Vector3.ZERO


# =========================
# VERIFICA DISTÂNCIA ENTRE GHOSTS
# =========================
func is_position_valid(pos: Vector3) -> bool:
	for existing_pos in spawned_positions:
		if pos.distance_to(existing_pos) < min_distance:
			return false
	return true

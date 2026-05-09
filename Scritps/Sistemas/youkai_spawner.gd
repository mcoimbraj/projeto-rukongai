extends Node3D

# =========================
# CONFIGURAÇÃO
# =========================

@export var ghost_scene: PackedScene
@export var spawn_count := 3
@export var floor_path: NodePath
@export var min_distance := 5.0
@export var margin := 2.0

# =========================
# VARIÁVEIS INTERNAS
# =========================

var map_min: Vector3
var map_max: Vector3
var spawned_positions: Array = []

# =========================
# INÍCIO
# =========================

func _ready():
	randomize()
	calculate_map_bounds()
	print("Spawner rodando")
	spawn_ghosts()

# =========================
# SPAWN
# =========================

func spawn_ghosts():
	if ghost_scene == null:
		print("❌ ERRO: ghost_scene está NULL")
		return

	spawned_positions.clear()

	for i in spawn_count:
		var ghost = ghost_scene.instantiate()

		var pos = get_valid_position()
		ghost.position = pos

		# 🔥 PEGA YOUKAI
		var youkai = YoukaiManager.get_random()

		if youkai == null:
			push_error("❌ Nenhum Youkai retornado pelo Manager!")
			return

		# 🔥 ATRIBUI NO GHOST
		ghost.youkai_data = youkai

		add_child(ghost)

		# DEBUG
		print("👻 Ghost spawnado:", youkai.name, "em", pos)

# =========================
# CALCULAR MAPA
# =========================

func calculate_map_bounds():
	var floor_node = get_node(floor_path)

	var mesh_instance = floor_node.find_child("MeshInstance3D", true, false)

	if mesh_instance == null:
		push_error("❌ MeshInstance3D não encontrado!")
		return

	var mesh = mesh_instance.mesh

	if mesh == null:
		push_error("❌ Mesh está vazio!")
		return

	var aabb = mesh.get_aabb()

	var size = aabb.size * mesh_instance.scale
	var pos = mesh_instance.global_position

	map_min = pos - size / 2
	map_max = pos + size / 2

	print("📍 Limites do mapa:")
	print("Min:", map_min)
	print("Max:", map_max)

# =========================
# POSIÇÃO VÁLIDA
# =========================

func get_valid_position() -> Vector3:
	var attempts := 0

	while attempts < 20:
		var pos = Vector3(
			randf_range(map_min.x + margin, map_max.x - margin),
			1,
			randf_range(map_min.z + margin, map_max.z - margin)
		)

		if is_position_valid(pos):
			spawned_positions.append(pos)
			return pos

		attempts += 1

	print("⚠ fallback de posição usado")

	return Vector3(
		randf_range(map_min.x, map_max.x),
		1,
		randf_range(map_min.z, map_max.z)
	)

# =========================
# EVITAR SOBREPOSIÇÃO
# =========================

func is_position_valid(pos: Vector3) -> bool:
	for p in spawned_positions:
		if pos.distance_to(p) < min_distance:
			return false
	return true
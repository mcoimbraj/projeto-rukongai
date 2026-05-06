extends Node
# Gerencia o banco de dados de youkais e fornece métodos de acesso
# Carrega os dados de youkais de arquivos .tres na pasta res://youkais	

# =========================
# BANCO DE DADOS
# =========================
var youkais: Array[Youkai] = []

# (opcional) cache por nome
var youkai_map: Dictionary = {}


# =========================
# INIT
# =========================
func _ready():
	load_youkai_data()
	print("👻 YoukaiManager carregado:", youkais.size(), "youkais")


# =========================
# CARREGAR TODOS OS .TRES
# =========================
func load_youkai_data():
	youkais.clear()
	youkai_map.clear()

	var dir_path = "res://youkais/"

	var dir = DirAccess.open(dir_path)
	if dir == null:
		push_error("❌ Pasta de youkais não encontrada: " + dir_path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres"):
			var path = dir_path + file_name
			var data: Youkai = load(path)

			if data:
				youkais.append(data)
				youkai_map[data.name] = data

		file_name = dir.get_next()

	dir.list_dir_end()


# =========================
# BUSCA SIMPLES
# =========================
func get_by_name(name: String) -> Youkai:
	return youkai_map.get(name, null)


# =========================
# RANDOM SIMPLES
# =========================
func get_random() -> Youkai:
	if youkais.is_empty():
		return null
	return youkais.pick_random()


# =========================
# FILTRO POR NATUREZA
# =========================
func get_by_nature(nature: String) -> Array[Youkai]:
	var result: Array[Youkai] = []

	for y in youkais:
		if y.nature_type == nature:
			result.append(y)

	return result


# =========================
# RANDOM POR NATUREZA
# =========================
func get_random_by_nature(nature: String) -> Youkai:
	var filtered = get_by_nature(nature)
	return filtered.pick_random() if not filtered.is_empty() else null


# =========================
# SPAWN HELPER (opcional)
# =========================
func spawn_youkai(scene: PackedScene, data: Youkai, parent: Node):
	var instance = scene.instantiate()

	instance.youkai_data = data

	parent.add_child(instance)
	return instance


# =========================
# DEBUG
# =========================
func print_all():
	for y in youkais:
		print("👻", y.name, "|", y.nature_type)
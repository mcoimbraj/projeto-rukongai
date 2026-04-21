extends Node

# =========================
# REFERÊNCIA DA CLASSE
# =========================
const Youkai = preload("res://classes/yokai.gd")

# =========================
# BANCO DE DADOS
# =========================
var youkais: Array[Youkai] = []

# =========================
# INIT
# =========================
func _ready():
	randomize()
	create_youkai()
	print("👻 YoukaiManager carregado:", youkais.size(), "youkais")


# =========================
# CRIAÇÃO DOS YOUKAIS
# =========================
func create_youkai():
	youkais.clear()

	# =========================
	# BASE
	# =========================
	add("Amari",
		"Mulher vestida de azul. Evite-a o quanto puder.",
		["Corte", "Velocidade"],
		"Vingativa"
	)

	add("HenoHeno",
		"Figura semelhante a um papel com rosto desenhado. Engana vítimas.",
		["Engano", "Furtividade"],
		"Enganadora"
	)

	add("Maria",
		"Espírito pacífico. Aceite seus presentes, mas mantenha distância.",
		["Calma", "Furtividade"],
		"Pacífica"
	)

	# =========================
	# EXPANSÃO (TESTES)
	# =========================
	add("Oni",
		"Força bruta e comportamento hostil.",
		["Força", "Resistência"],
		"Hostil"
	)

	add("Kage",
		"Sombra viva que observa silenciosamente.",
		["Furtividade", "Velocidade"],
		"Agressiva"
	)

	add("Yurei",
		"Alma presa ao mundo dos vivos.",
		["Medo", "Velocidade"],
		"Vingativa"
	)

	add("Noppera-bo",
		"Ser sem rosto que causa pânico.",
		["Engano", "Medo"],
		"Enganadora"
	)

	add("Kodama",
		"Espírito da floresta.",
		["Calma", "Engano"],
		"Neutra"
	)

	add("Tsuchigumo",
		"Criatura semelhante a uma aranha gigante.",
		["Força", "Veneno"],
		"Hostil"
	)


# =========================
# FUNÇÃO AUXILIAR
# =========================
func add(name: String, desc: String, hab: Array, nat: String):
	var y = Youkai.new(name, desc, hab, nat)
	youkais.append(y)


# =========================
# RANDOM SIMPLES
# =========================
func get_random_youkai() -> Youkai:
	if youkais.is_empty():
		push_warning("⚠ Lista de youkais vazia!")
		return null

	return youkais.pick_random()


# =========================
# FILTRO POR NATUREZA
# =========================
func get_youkai_by_nature(nature: String) -> Array[Youkai]:
	var result: Array[Youkai] = []

	for y in youkais:
		if y.natureza == nature:
			result.append(y)

	return result


# =========================
# RANDOM POR NATUREZA
# =========================
func get_random_by_nature(nature: String) -> Youkai:
	var filtered = get_youkai_by_nature(nature)

	if filtered.is_empty():
		push_warning("⚠ Nenhum youkai encontrado para: " + nature)
		return null

	return filtered.pick_random()


# =========================
# RANDOM INTELIGENTE (OPCIONAL)
# =========================
func get_weighted_random() -> Youkai:
	# Exemplo simples de raridade
	var roll = randf()

	if roll < 0.5:
		return get_random_by_nature("Enganadora")

	elif roll < 0.8:
		return get_random_by_nature("Vingativa")

	else:
		return get_random_youkai()


# =========================
# DEBUG
# =========================
func print_all():
	for y in youkais:
		print("👻", y.name, "|", y.natureza)
extends Node
class_name YoukaiManager

# Lista de todos os youkai do jogo
var youkais: Array[Youkai] = []

func _ready():
    create_youkai()

# =========================
# CRIAÇÃO DOS YOUKAI
# =========================
func create_youkai():
    var amari = Youkai.new(
        "Amari",
        "A figura de uma mulher vestida de azul. Evite-a o quanto puder.",
        ["Corte", "Velocidade"],
        "Vingativa"
    )

    var henoheno = Youkai.new(
        "HenoHeno",
        "Uma figura que se assemelha a um papel com uma face desenhada. Ele engana as pessoas com sua lábia.",
        ["Engano", "Furtividade"],
        "Enganadora"
    )

    var maria = Youkai.new(
        "Maria",
        "Uma entidade pacífica e amigável. Aceite seus presentes, mas não se aproxime demais.",
        ["Calma", "Furtividade"],
        "Pacífica"
    )

    youkais.append_array([amari, henoheno, maria])


# =========================
# PEGAR YOUKAI ALEATÓRIO
# =========================
func get_random_youkai() -> Youkai:
    if youkais.is_empty():
        push_warning("Lista de youkais está vazia!")
        return null

    return youkais.pick_random()


# =========================
# FILTRAR POR NATUREZA
# =========================
func get_youkai_by_nature(nature: String) -> Array[Youkai]:
    var result: Array[Youkai] = []

    for y in youkais:
        if y.natureza == nature:
            result.append(y)

    return result


# =========================
# PEGAR ALEATÓRIO POR NATUREZA
# =========================
func get_random_by_nature(nature: String) -> Youkai:
    var filtered = get_youkai_by_nature(nature)

    if filtered.is_empty():
        push_warning("Nenhum youkai encontrado para a natureza: " + nature)
        return null

    return filtered.pick_random()
extends Resource
class_name Youkai

# =========================
# CONSTANTES (AÇÕES)
# =========================
const FRASE_IDLE   := "idle"
const FRASE_ATTACK := "attack"
const FRASE_DAMAGE := "damage"
const FRASE_DEATH  := "death"
const FRASE_PUZZLE := "puzzle"

# =========================
# IDENTIFICAÇÃO
# =========================
@export var name: String
@export var description: String
@export var historia: String
@export var historia_antiqua: String
@export var natureza: String

# =========================
# FRASES
# =========================
@export var frases: Array[String] = []

@export var frases_acao: Dictionary = {
	FRASE_IDLE: [],
	FRASE_ATTACK: [],
	FRASE_DAMAGE: [],
	FRASE_DEATH: [],
	FRASE_PUZZLE: []
}

# =========================
# COMBATE
# =========================
@export var hp: int
@export var attack: int
@export var defense: int
@export var dodge_chance: float
@export var crit_chance: float
@export var crit_multiplier: float
@export var fasmofobia: int

#=======================
# COMPORTAMENTOS
#=======================

@export var nature_type: String
@export var move_speed: float
@export var detection_range: float
@export var sneak_speed: float

# =========================
# PUZZLE
# =========================
@export var puzzle: PuzzleData


# =========================
# CONSTRUCTOR
# =========================
func _init(
	_name: String = "",
	_desc: String = "",
	_historia: String = "",
	_historia_antiqua: String = "",
	_natureza: String = "",
	_frases: Array[String] = []
):
	name = _name
	description = _desc
	historia = _historia
	historia_antiqua = _historia_antiqua
	natureza = _natureza

	frases = _frases.duplicate()

	# garante estrutura segura dos dicionários
	frases_acao = {
		FRASE_IDLE: [],
		FRASE_ATTACK: [],
		FRASE_DAMAGE: [],
		FRASE_DEATH: [],
		FRASE_PUZZLE: []
	}


# =========================
# FRASES SIMPLES
# =========================
func get_random_frase() -> String:
	if frases.is_empty():
		return ""
	return frases.pick_random()


# =========================
# FRASES POR AÇÃO
# =========================
func get_frase_acao(tipo: String) -> String:
	if not frases_acao.has(tipo):
		return ""

	var lista: Array = frases_acao[tipo]
	if lista.is_empty():
		return ""

	return lista.pick_random()
extends Resource
class_name Youkai

# =========================
# PROPRIEDADES (VISÍVEIS NO INSPECTOR)
# =========================
@export var name: String
@export var description: String
@export var abilities: Array
@export var natureza: String

# =========================
# CONSTRUTOR
# =========================
func _init(_name: String = "", _description: String = "", _abilities: Array = [], _natureza: String = ""):
	name = _name
	description = _description
	abilities = _abilities
	natureza = _natureza
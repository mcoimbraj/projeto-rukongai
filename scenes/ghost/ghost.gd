extends Node3D

@export var youkai_data: Youkai

var triggered := false

func _ready():
	# evita conectar duas vezes (bug comum)
	if not $Area3D.body_entered.is_connected(_on_body_entered):
		$Area3D.body_entered.connect(_on_body_entered)

	if youkai_data == null:
		youkai_data = YoukaiManager.get_random_youkai()

	print("Ghost recebeu:", youkai_data.name)

func _on_body_entered(body):
	if triggered:
		return

	if body.is_in_group("player"):
		triggered = true
		start_encounter()

func start_encounter():
	print("Encontro iniciado com:", youkai_data.name)

	# 🔥 PAUSA O JOGO
	get_tree().paused = true

	# 🔥 instancia batalha
	var battle = load("scenes\\screens\\battle.tscn").instantiate()
	battle.set_youkai(youkai_data)

	# 🔥 adiciona na tela
	get_tree().root.add_child(battle)

	# 🔥 conecta fim da batalha
	battle.tree_exited.connect(_on_battle_finished)

	# (opcional) esconde o ghost
	visible = false


func _on_battle_finished():
	print("Batalha terminou")

	# 🔥 DESPAUSA O JOGO
	get_tree().paused = false

	# 🔥 remove o ghost definitivamente
	queue_free()

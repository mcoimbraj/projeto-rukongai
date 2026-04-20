extends Node3D

@export var youkai_data: Youkai

var triggered := false  # evita repetir o evento

func _ready():
	# conecta o sinal da área
	$Area3D.body_entered.connect(_on_body_entered)
	if youkai_data == null:
		youkai_data = YoukaiManager.youkais.pick_random()

	print("Ghost recebeu: ", youkai_data.name)

func _on_body_entered(body):
	if triggered:
		return

	if body.is_in_group("player"):
		triggered = true
		start_encounter()

func start_encounter():
	print("Encontro iniciado com: ", youkai_data.name)
	get_tree().change_scene_to_file("res://scenes/battle.tscn")

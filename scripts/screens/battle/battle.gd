extends Control

# =========================
# DADOS
# =========================

var youkai
var player_hp := 20
var enemy_hp := 15
var player_turn := true

# UI
var lbl_name
var lbl_player_hp
var lbl_enemy_hp
var btn_attack
var btn_flee

# =========================
# INIT
# =========================

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	build_ui()
	update_ui()

	print("⚔️ Encontro com:", youkai.name)

# =========================
# RECEBE YOUKAI
# =========================

func set_youkai(y):
	youkai = y

# =========================
# CRIA UI VIA CÓDIGO
# =========================

func build_ui():
	# Fundo (opcional)
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.8)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Nome do inimigo
	lbl_name = Label.new()
	lbl_name.position = Vector2(20, 20)
	lbl_name.scale = Vector2(1.5, 1.5)
	add_child(lbl_name)

	# HP Player
	lbl_player_hp = Label.new()
	lbl_player_hp.position = Vector2(20, 80)
	add_child(lbl_player_hp)

	# HP Enemy
	lbl_enemy_hp = Label.new()
	lbl_enemy_hp.position = Vector2(20, 120)
	add_child(lbl_enemy_hp)

	# Botão atacar
	btn_attack = Button.new()
	btn_attack.text = "Atacar"
	btn_attack.position = Vector2(20, 200)
	btn_attack.pressed.connect(_on_attack_pressed)
	add_child(btn_attack)

	# Botão fugir
	btn_flee = Button.new()
	btn_flee.text = "Fugir"
	btn_flee.position = Vector2(150, 200)
	btn_flee.pressed.connect(_on_flee_pressed)
	add_child(btn_flee)

# =========================
# UI UPDATE
# =========================

func update_ui():
	if youkai != null:
		lbl_name.text = "👻 " + youkai.name

	lbl_player_hp.text = "❤️ Player: " + str(player_hp)
	lbl_enemy_hp.text = "💀 Enemy: " + str(enemy_hp)

# =========================
# COMBATE
# =========================

func _on_attack_pressed():
	if not player_turn:
		return

	var damage = randi_range(2, 5)
	enemy_hp -= damage

	print("🗡️ Você causou", damage, "de dano!")

	player_turn = false
	update_ui()
	check_end()

	if enemy_hp > 0:
		await get_tree().create_timer(1.0).timeout
		enemy_turn()

func enemy_turn():
	var damage = randi_range(1, 4)
	player_hp -= damage

	print("👻", youkai.name, "te causou", damage, "de dano!")

	player_turn = true
	update_ui()
	check_end()

# =========================
# AÇÕES
# =========================

func _on_flee_pressed():
	print("🏃 Você fugiu!")
	end_battle()

# =========================
# FINAL
# =========================

func check_end():
	if enemy_hp <= 0:
		print("🏆 Vitória!")
		end_battle()

	elif player_hp <= 0:
		print("💀 Derrota...")
		end_battle()

func end_battle():
	await get_tree().create_timer(1.0).timeout
	queue_free()
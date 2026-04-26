extends Control

# =========================
# DADOS
# =========================
var youkai

var player_hp := 20
var player_max_hp := 20

var enemy_hp := 15
var enemy_max_hp := 15

var player_turn := true

# UI elements
var lbl_name
var player_hp_bar
var enemy_hp_bar
var btn_attack
var btn_negotiate
var btn_dodge
var btn_items
var btn_flee
var msg_label

# =========================
# RECEBE YOUKAI
# =========================
func set_youkai(y):
	youkai = y
	
	if youkai != null and youkai.has_method("get"):
		if "hp" in youkai:
			enemy_hp = youkai.hp
			enemy_max_hp = youkai.hp
		else:
			enemy_hp = 15
			enemy_max_hp = 15

# =========================
# INIT
# =========================
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	build_ui()
	update_ui()
	
	if youkai:
		print("⚔️ Encontro com:", youkai.name)
	else:
		print("⚔️ Encontro com: Desconhecido")

# =========================
# UI
# =========================
func build_ui():
	# Fundo escuro
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Container principal
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.custom_minimum_size = Vector2(400, 450)
	add_child(vbox)
	
	# Nome
	lbl_name = Label.new()
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name.add_theme_font_size_override("font_size", 28)
	vbox.add_child(lbl_name)
	
	vbox.add_child(HSeparator.new())
	
	# =========================
	# HP
	# =========================
	var hbox_hp = HBoxContainer.new()
	hbox_hp.add_theme_constant_override("separation", 20)
	vbox.add_child(hbox_hp)
	
	# PLAYER
	var p_container = VBoxContainer.new()
	p_container.size_flags_horizontal = Control.SIZE_EXPAND
	
	var p_label = Label.new()
	p_label.text = "Você"
	p_container.add_child(p_label)
	
	player_hp_bar = ProgressBar.new()
	player_hp_bar.max_value = player_max_hp
	player_hp_bar.value = player_hp
	player_hp_bar.show_percentage = true  # ✅ CORRIGIDO
	p_container.add_child(player_hp_bar)
	
	hbox_hp.add_child(p_container)
	
	# ENEMY
	var e_container = VBoxContainer.new()
	e_container.size_flags_horizontal = Control.SIZE_EXPAND
	
	var e_label = Label.new()
	e_label.text = "Inimigo"
	e_container.add_child(e_label)
	
	enemy_hp_bar = ProgressBar.new()
	enemy_hp_bar.max_value = enemy_max_hp
	enemy_hp_bar.value = enemy_hp
	enemy_hp_bar.show_percentage = true  # ✅ CORRIGIDO
	e_container.add_child(enemy_hp_bar)
	
	hbox_hp.add_child(e_container)
	
	vbox.add_child(HSeparator.new())
	
	# =========================
	# BOTÕES
	# =========================
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 15)
	grid.add_theme_constant_override("v_separation", 15)
	vbox.add_child(grid)
	
	var btn_size = Vector2(140, 80)
	
	btn_attack = Button.new()
	btn_attack.text = "⚔️ Atacar"
	btn_attack.custom_minimum_size = btn_size
	btn_attack.pressed.connect(_on_attack_pressed)
	grid.add_child(btn_attack)
	
	btn_negotiate = Button.new()
	btn_negotiate.text = "🤝 Negociar"
	btn_negotiate.custom_minimum_size = btn_size
	btn_negotiate.pressed.connect(_on_negotiate_pressed)
	grid.add_child(btn_negotiate)
	
	btn_dodge = Button.new()
	btn_dodge.text = "💨 Esquivar"
	btn_dodge.custom_minimum_size = btn_size
	btn_dodge.pressed.connect(_on_dodge_pressed)
	grid.add_child(btn_dodge)
	
	btn_items = Button.new()
	btn_items.text = "🎒 Itens"
	btn_items.custom_minimum_size = btn_size
	btn_items.pressed.connect(_on_items_pressed)
	grid.add_child(btn_items)
	
	btn_flee = Button.new()
	btn_flee.text = "🏃 Fugir"
	btn_flee.custom_minimum_size = btn_size
	btn_flee.pressed.connect(_on_flee_pressed)
	grid.add_child(btn_flee)
	
	# =========================
	# MENSAGEM
	# =========================
	msg_label = Label.new()
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg_label.add_theme_color_override("font_color", Color.YELLOW)
	msg_label.text = ""
	vbox.add_child(msg_label)

# =========================
# UPDATE UI
# =========================
func update_ui():
	if youkai:
		lbl_name.text = "👻 " + youkai.name
	else:
		lbl_name.text = "👻 Desconhecido"
	
	player_hp_bar.value = player_hp
	player_hp_bar.max_value = player_max_hp
	
	enemy_hp_bar.value = enemy_hp
	enemy_hp_bar.max_value = enemy_max_hp

# =========================
# COMBATE
# =========================
func _on_attack_pressed():
	if not player_turn:
		return
	
	var damage = randi_range(2, 5)
	enemy_hp -= damage
	
	msg_label.text = "🗡️ Você causou " + str(damage) + " de dano!"
	
	player_turn = false
	update_ui()
	check_end()
	
	if enemy_hp > 0:
		await get_tree().create_timer(1.0).timeout
		enemy_turn()

func enemy_turn():
	var damage = randi_range(1, 4)
	player_hp -= damage
	
	msg_label.text = "👻 " + (youkai.name if youkai else "Inimigo") + " causou " + str(damage) + " de dano!"
	
	player_turn = true
	update_ui()
	check_end()

# =========================
# AÇÕES
# =========================
func _on_negotiate_pressed():
	if not player_turn:
		return
	
	if randf() < 0.5:
		msg_label.text = "🤝 Sucesso! O youkai se acalma."
		end_battle(true)
	else:
		msg_label.text = "😠 Falhou! Ele ataca."
		player_turn = false
		await get_tree().create_timer(1.0).timeout
		enemy_turn()

func _on_dodge_pressed():
	if not player_turn:
		return
	
	msg_label.text = "💨 Você escapou."
	end_battle(false)

func _on_items_pressed():
	if not player_turn:
		return
	
	player_hp = min(player_hp + 5, player_max_hp)
	msg_label.text = "💊 +5 HP"
	update_ui()
	
	player_turn = false
	await get_tree().create_timer(1.0).timeout
	enemy_turn()

func _on_flee_pressed():
	if not player_turn:
		return
	
	if randf() < 0.5:
		msg_label.text = "🏃 Fugiu com sucesso!"
		end_battle(false)
	else:
		msg_label.text = "😫 Falha!"
		player_turn = false
		await get_tree().create_timer(1.0).timeout
		enemy_turn()

# =========================
# FINAL
# =========================
func check_end():
	if enemy_hp <= 0:
		msg_label.text = "🏆 Vitória!"
		end_battle(true)
	elif player_hp <= 0:
		msg_label.text = "💀 Derrota..."
		end_battle(false)

func end_battle(_victory):
	disable_buttons()
	await get_tree().create_timer(1.5).timeout
	queue_free()

func disable_buttons():
	btn_attack.disabled = true
	btn_negotiate.disabled = true
	btn_dodge.disabled = true
	btn_items.disabled = true
	btn_flee.disabled = true

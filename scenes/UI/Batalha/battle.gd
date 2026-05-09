extends Control

# =========================
# DADOS
# =========================
var youkai

var player_hp := 20
var player_max_hp := 20

var enemy_hp := 35
var enemy_max_hp := 35

var player_turn := true

# =========================
# UI
# =========================
@onready var player_hp_bar = $CenterContainer/VBoxContainer/player/barras_juntas/player_hp
@onready var player_hp_bar_lag = $CenterContainer/VBoxContainer/player/barras_juntas/player_hp_lag

@onready var enemy_hp_bar = $CenterContainer/VBoxContainer/enemy/barras_juntas/enemy_hp
@onready var enemy_hp_lag = $CenterContainer/VBoxContainer/enemy/barras_juntas/enemy_hp_lag

@onready var enemy_label = $CenterContainer/VBoxContainer/enemy/e_label

@onready var btn_attack = $CenterContainer/VBoxContainer/MarginContainer/buttons/btn_attack
@onready var btn_negotiate = $CenterContainer/VBoxContainer/MarginContainer/buttons/btn_negotiate
@onready var btn_items = $CenterContainer/VBoxContainer/MarginContainer/buttons/btn_items
@onready var btn_flee = $CenterContainer/VBoxContainer/MarginContainer/buttons/btn_flee

@onready var msg_label = $CenterContainer/VBoxContainer/msg_label

# =========================
# RECEBE YOUKAI
# =========================
func set_youkai(y):
	youkai = y
	
	if youkai and "hp" in youkai:
		enemy_hp = youkai.hp
		enemy_max_hp = youkai.hp

# =========================
# INIT
# =========================
func _ready():

	process_mode = Node.PROCESS_MODE_ALWAYS
	# 🔴 Remove o "0%" das barras
	player_hp_bar.show_percentage = false
	player_hp_bar_lag.show_percentage = false
	enemy_hp_bar.show_percentage = false
	enemy_hp_lag.show_percentage = false
	
	# 🔴 Garante valores iniciais corretos (ESSENCIAL)
	player_hp_bar.max_value = player_max_hp
	player_hp_bar.value = player_hp
	
	player_hp_bar_lag.max_value = player_max_hp
	player_hp_bar_lag.value = player_hp
	
	enemy_hp_bar.max_value = enemy_max_hp
	enemy_hp_bar.value = enemy_hp
	
	enemy_hp_lag.max_value = enemy_max_hp
	enemy_hp_lag.value = enemy_hp

	update_ui()

# =========================
# UPDATE UI
# =========================
func update_ui():
	# Nome dinâmico
	if enemy_label:
		enemy_label.text = youkai.name if youkai else "Inimigo"

	# ================= PLAYER =================
	player_hp_bar.max_value = player_max_hp
	player_hp_bar_lag.max_value = player_max_hp

	var tween_p = create_tween()
	tween_p.tween_property(player_hp_bar, "value", player_hp, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	var tween_p_lag = create_tween()
	tween_p_lag.tween_property(player_hp_bar_lag, "value", player_hp, 1.0)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)

	# ================= ENEMY =================
	enemy_hp_bar.max_value = enemy_max_hp
	enemy_hp_lag.max_value = enemy_max_hp

	var tween_e = create_tween()
	tween_e.tween_property(enemy_hp_bar, "value", enemy_hp, 0.6)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	var tween_e_lag = create_tween()
	tween_e_lag.tween_property(enemy_hp_lag, "value", enemy_hp, 0.8)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)

# =========================
# COMBATE
# =========================
func _on_attack_pressed():
	if not player_turn:
		return
	
	var damage = randi_range(2, 5)
	enemy_hp -= damage
	
	msg_label.text = "🗡️ Você causou %d de dano!" % damage
	
	player_turn = false
	update_ui()
	check_end()
	
	if enemy_hp > 0:
		await get_tree().create_timer(1.0).timeout
		enemy_turn()

func enemy_turn():
	var damage = randi_range(1, 4)
	player_hp -= damage
	
	var enemy_name = youkai.name if youkai else "Inimigo"
	msg_label.text = "👻 %s causou %d de dano!" % [enemy_name, damage]
	
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
		msg_label.text = "🤝 Sucesso!"
		end_battle(true)
	else:
		msg_label.text = "😠 Falhou!"
		player_turn = false
		await get_tree().create_timer(1.0).timeout
		enemy_turn()

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
		msg_label.text = "🏃 Fugiu!"
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
	btn_items.disabled = true
	btn_flee.disabled = true

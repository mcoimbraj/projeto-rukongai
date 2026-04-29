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

# =========================
# UI (referências da cena)
# =========================
@onready var lbl_name = $CenterContainer/MarginContainer/PanelContainer/VBoxContainer/lbl_name

@onready var player_hp_bar = $CenterContainer/MarginContainer/PanelContainer/VBoxContainer/hp_box/player/player_hp
@onready var enemy_hp_bar = $CenterContainer/MarginContainer/PanelContainer/VBoxContainer/hp_box/enemy/enemy_hp

@onready var btn_attack = $CenterContainer/MarginContainer/PanelContainer/VBoxContainer/buttons/btn_attack
@onready var btn_negotiate = $CenterContainer/MarginContainer/PanelContainer/VBoxContainer/buttons/btn_negotiate
@onready var btn_items = $CenterContainer/MarginContainer/PanelContainer/VBoxContainer/buttons/btn_items
@onready var btn_flee = $CenterContainer/MarginContainer/PanelContainer/VBoxContainer/buttons/btn_flee

@onready var msg_label = $CenterContainer/MarginContainer/PanelContainer/VBoxContainer/msg_label

# =========================
# RECEBE YOUKAI
# =========================
func set_youkai(y):
	youkai = y
	
	if youkai and "hp" in youkai:
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
	
	update_ui()
	
	if youkai:
		print("⚔️ Encontro com:", youkai.name)
	else:
		print("⚔️ Encontro com: Desconhecido")

# =========================
# UPDATE UI
# =========================
func update_ui():
	lbl_name.text = "👻 " + (youkai.name if youkai else "Desconhecido")
	
	player_hp_bar.max_value = player_max_hp
	player_hp_bar.value = player_hp
	
	enemy_hp_bar.max_value = enemy_max_hp
	enemy_hp_bar.value = enemy_hp

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
		msg_label.text = "🤝 Sucesso! O youkai se acalma."
		end_battle(true)
	else:
		msg_label.text = "😠 Falhou! Ele ataca."
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
	btn_items.disabled = true
	btn_flee.disabled = true

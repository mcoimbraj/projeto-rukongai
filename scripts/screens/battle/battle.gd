extends Control

# =========================
# DADOS
# =========================
var youkai
var player_hp := 20
var enemy_hp := 15
var player_turn := true
var player_max_hp := 20
var enemy_max_hp := 15

# UI Elements
var bg_panel : Panel
var vbox_main : VBoxContainer
var lbl_name : Label
var hbox_hps : HBoxContainer
var player_hp_bar : ProgressBar
var enemy_hp_bar : ProgressBar
var hbox_buttons : HBoxContainer
var btn_attack : Button
var btn_negotiate : Button
var btn_dodge : Button
var btn_items : Button
var btn_flee : Button
var msg_label : Label

# Inventário (exemplo simples – você pode integrar com seu sistema de itens)
var inventory = ["Poção Pequena", "Poção Pequena"]  # nomes de itens

# =========================
# INIT
# =========================
func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    build_ui()
    update_ui()
    print("⚔️ Encontro com:", youkai.name)

func set_youkai(y):
    youkai = y

# =========================
# CONSTRUÇÃO DA UI RESPONSIVA
# =========================
func build_ui():
    # Fundo escuro semitransparente (cobre toda a tela)
    bg_panel = Panel.new()
    bg_panel.color = Color(0, 0, 0, 0.85)
    bg_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg_panel)

    # Container principal vertical (centralizado na tela)
    vbox_main = VBoxContainer.new()
    vbox_main.set_anchors_preset(Control.PRESET_CENTER)   # ancora no centro
    vbox_main.set_offsets_preset(Control.PRESET_CENTER)
    vbox_main.size = Vector2(400, 500)   # largura fixa mas altura flexível
    vbox_main.alignment = BoxContainer.ALIGNMENT_CENTER
    add_child(vbox_main)

    # Nome do youkai
    lbl_name = Label.new()
    lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lbl_name.add_theme_font_size_override("font_size", 28)
    lbl_name.add_theme_color_override("font_color", Color.WHITE)
    vbox_main.add_child(lbl_name)

    vbox_main.add_child(HSeparator.new())

    # HBox para as duas barras de HP
    hbox_hps = HBoxContainer.new()
    hbox_hps.add_theme_constant_override("separation", 20)
    vbox_main.add_child(hbox_hps)

    # Barra de HP do player
    var player_container = VBoxContainer.new()
    player_container.size_flags_horizontal = Control.SIZE_EXPAND
    var lbl_player = Label.new()
    lbl_player.text = "Você"
    lbl_player.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    player_container.add_child(lbl_player)
    player_hp_bar = ProgressBar.new()
    player_hp_bar.max = player_max_hp
    player_hp_bar.value = player_hp
    player_hp_bar.percent_visible = true
    player_hp_bar.add_theme_stylebox_override("fill", preload("res://theme/bar_fill_red.tres")) # opcional
    player_container.add_child(player_hp_bar)
    hbox_hps.add_child(player_container)

    # Barra de HP do inimigo
    var enemy_container = VBoxContainer.new()
    enemy_container.size_flags_horizontal = Control.SIZE_EXPAND
    var lbl_enemy = Label.new()
    lbl_enemy.text = "Inimigo"
    lbl_enemy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    enemy_container.add_child(lbl_enemy)
    enemy_hp_bar = ProgressBar.new()
    enemy_hp_bar.max = enemy_max_hp
    enemy_hp_bar.value = enemy_hp
    enemy_hp_bar.percent_visible = true
    enemy_container.add_child(enemy_hp_bar)
    hbox_hps.add_child(enemy_container)

    vbox_main.add_child(HSeparator.new())

    # Container de botões (horizontal, com quebra automática se não couber)
    hbox_buttons = HBoxContainer.new()
    hbox_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
    hbox_buttons.add_theme_constant_override("separation", 15)
    vbox_main.add_child(hbox_buttons)

    # Botões com tamanho mínimo para dedo (80x80)
    var btn_size = Vector2(100, 80)

    btn_attack = Button.new()
    btn_attack.text = "⚔️ Atacar"
    btn_attack.custom_minimum_size = btn_size
    btn_attack.pressed.connect(_on_attack_pressed)
    hbox_buttons.add_child(btn_attack)

    btn_negotiate = Button.new()
    btn_negotiate.text = "🤝 Negociar"
    btn_negotiate.custom_minimum_size = btn_size
    btn_negotiate.pressed.connect(_on_negotiate_pressed)
    hbox_buttons.add_child(btn_negotiate)

    btn_dodge = Button.new()
    btn_dodge.text = "💨 Esquivar"
    btn_dodge.custom_minimum_size = btn_size
    btn_dodge.pressed.connect(_on_dodge_pressed)
    hbox_buttons.add_child(btn_dodge)

    btn_items = Button.new()
    btn_items.text = "🎒 Itens"
    btn_items.custom_minimum_size = btn_size
    btn_items.pressed.connect(_on_items_pressed)
    hbox_buttons.add_child(btn_items)

    btn_flee = Button.new()
    btn_flee.text = "🏃 Fugir"
    btn_flee.custom_minimum_size = btn_size
    btn_flee.pressed.connect(_on_flee_pressed)
    hbox_buttons.add_child(btn_flee)

    # Mensagens de turno (por exemplo "Você causou 4 de dano!")
    msg_label = Label.new()
    msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    msg_label.add_theme_font_size_override("font_size", 18)
    msg_label.text = ""
    vbox_main.add_child(msg_label)

    # Ajuste fino: garantir que o vbox_main fique visível mesmo em resoluções baixas
    vbox_main.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)

func update_ui():
    if youkai:
        lbl_name.text = "👻 " + youkai.name
    player_hp_bar.value = player_hp
    enemy_hp_bar.value = enemy_hp

# =========================
# AÇÕES DO JOGADOR
# =========================
func _on_attack_pressed():
    if not player_turn: return
    var damage = randi_range(2, 5)
    enemy_hp -= damage
    msg_label.text = "🗡️ Você causou %d de dano!" % damage
    player_turn = false
    update_ui()
    check_end()
    if enemy_hp > 0:
        await get_tree().create_timer(1.0).timeout
        enemy_turn()

func _on_negotiate_pressed():
    if not player_turn: return
    # Exemplo simples: charada ou teste de sorte
    var success = randi() % 2 == 0   # 50% de chance
    if success:
        msg_label.text = "🤝 Você negociou com sucesso! O youkai se acalmou."
        # Ganha XP, item ou simplesmente termina a batalha sem dano
        end_battle(true)  # vitória pacífica
    else:
        msg_label.text = "😠 A negociação falhou! O youkai ataca com fúria."
        player_turn = false
        update_ui()
        # Inimigo contra-ataca imediatamente
        enemy_turn()

func _on_dodge_pressed():
    if not player_turn: return
    msg_label.text = "💨 Você usou a Esquiva! O combate é interrompido sem consequências."
    # Termina a batalha sem vitória nem derrota – o ghost desaparece
    end_battle(false, false)  # nem vitória nem derrota

func _on_items_pressed():
    if not player_turn: return
    # Abre uma seleção de itens (pode ser um popup)
    # Exemplo simples: cura com poção
    if inventory.has("Poção Pequena"):
        inventory.erase("Poção Pequena")
        player_hp = min(player_hp + 10, player_max_hp)
        msg_label.text = "💊 Você usou uma Poção Pequena. HP +10"
        update_ui()
        player_turn = false
        await get_tree().create_timer(1.0).timeout
        enemy_turn()
    else:
        msg_label.text = "❌ Nenhum item útil disponível!"

func _on_flee_pressed():
    if not player_turn: return
    var flee_chance = 0.5  # 50% de sucesso
    if randf() < flee_chance:
        msg_label.text = "🏃 Você fugiu com sucesso!"
        end_battle(false, false)
    else:
        msg_label.text = "😫 Falha ao fugir! O youkai bloqueia a saída."
        player_turn = false
        update_ui()
        enemy_turn()

# =========================
# TURNO DO INIMIGO
# =========================
func enemy_turn():
    var damage = randi_range(1, 4)
    player_hp -= damage
    msg_label.text = "👻 %s causou %d de dano!" % [youkai.name, damage]
    player_turn = true
    update_ui()
    check_end()

# =========================
# FIM DA BATALHA
# =========================
func check_end():
    if enemy_hp <= 0:
        msg_label.text = "🏆 Vitória! Você derrotou o youkai."
        end_battle(true)
    elif player_hp <= 0:
        msg_label.text = "💀 Derrota... Você foi derrotado."
        end_battle(false)

func end_battle(victory: bool = false, victory_exp: bool = true):
    # Desabilita todos os botões para evitar múltiplos cliques
    disable_buttons()
    # Aguarda 1.5 segundos para ler a mensagem final
    await get_tree().create_timer(1.5).timeout
    # Emite sinal ou chama método para dar recompensas (XP, itens)
    if victory and victory_exp:
        print("Recompensa concedida!")
        # Exemplo: adicionar item, ganhar XP
    queue_free()

func disable_buttons():
    btn_attack.disabled = true
    btn_negotiate.disabled = true
    btn_dodge.disabled = true
    btn_items.disabled = true
    btn_flee.disabled = true
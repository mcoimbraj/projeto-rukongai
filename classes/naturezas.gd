extends Resource
class_name Naturezas

func escolher_acao(user, target):
    # Naturalmente parado e analítico;
    return "idle" 
func quando_interage_com(player):
    # Lógica para interagir com o jogador com base na natureza do youkai
    pass

func quando_leva_dano(user, player):
    # Lógica para lidar com o dano com base na natureza do youkai
    pass

func quando_jogador_foge(user, player):
    # Lógica para lidar com o jogador fugindo com base na natureza do youkai
    pass

func stalker(player) -> bool:
    # Lógica para o comportamento de perseguição com base na natureza do youkai
    pass
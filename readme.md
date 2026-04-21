
# 📘 Projeto: Rukongai
**Aluno:** Milton Coimbra Júnior  
**Disciplina:** Projeto de Software  
**Professor:** Dr. Baldoino Fonseca dos Santos Neto  

---

# 🎮 1. Visão Geral do Projeto

**Rukongai** é um jogo para dispositivos móveis (Android) com temática sobrenatural, focado na investigação e confronto com entidades espirituais chamadas *Youkai*.

O diferencial do projeto está em:

- Uso de **sensores do celular (giroscópio e acelerômetro)** para navegação
- Exploração do ambiente físico convertida em movimentação virtual
- Sistema de encontros aleatórios com entidades
- Combate estratégico simplificado (turn-based)

---

# 🧠 2. Conceito de Gameplay

O jogador:

1. **Se movimenta fisicamente** (ou simulado no PC)
2. Explora um mapa virtual
3. Encontra entidades (fantasmas / youkai)
4. Ao colidir → inicia batalha
5. Decide ações:
   - Atacar
   - Fugir
   - (futuramente: negociar, puzzles)

---

# 🧱 3. Arquitetura do Sistema

O projeto segue uma estrutura modular baseada em:

- **Entidades (Resources)**
- **Sistemas (Managers / Spawners)**
- **Cenas (Scenes)**
- **Scripts de comportamento**

---

# 📂 4. Estrutura de Arquivos

```

res://
│
├── classes/
│   ├── yokai.gd
│   └── item.gd
│
├── scripts/
│   ├── player/
│   │   └── player.gd
│   │
│   ├── ghost/
│   │   └── ghost.gd
│   │
│   ├── systems/
│   │   ├── youkai_manager.gd
│   │   └── youkai_spawner.gd
│   │
│   └── screens/
│       └── battle/
│           └── battle.gd
│
├── scenes/
│   ├── main/
│   │   └── main.tscn
│   │
│   ├── player/
│   │   └── player.tscn
│   │
│   ├── ghosts/
│   │   └── ghost.tscn
│   │
│   └── battle.tscn
│
└── youkais/
└── amari.tres

````

---

# ⚙️ 5. Função de Cada Arquivo

---

## 🧬 `classes/yokai.gd`

Define a estrutura de um Youkai (entidade inimiga):

```gdscript
class_name Youkai
````

Contém:

* Nome
* Descrição
* Habilidades
* Natureza

👉 Atua como **modelo de dados (Data Model)**

---

## 👤 `scripts/player/player.gd`

Responsável pelo controle do jogador.

### Funções principais:

* Movimentação via:

  * PC (WASD + mouse)
  * Mobile (giroscópio + acelerômetro)
* Rotação da câmera
* Integração com física (`move_and_slide`)

👉 Representa a camada de **entrada e navegação**

---

## 👻 `scripts/ghost/ghost.gd`

Controla o comportamento dos fantasmas no mapa.

### Funções:

* Detecta colisão com o player (`Area3D`)
* Dispara encontro
* Instancia a cena de batalha
* Envia o Youkai correspondente

```gdscript
battle.set_youkai(youkai_data)
```

👉 Atua como **gatilho de eventos**

---

## 🧠 `scripts/systems/youkai_manager.gd`

Gerencia todos os Youkai do jogo.

### Funções:

* Criar lista de entidades
* Retornar Youkai aleatório
* Filtrar por natureza

👉 Atua como **repositório central de dados**

---

## 🌀 `scripts/systems/youkai_spawner.gd`

Responsável por gerar fantasmas no mapa.

### Funções:

* Instanciar fantasmas
* Distribuir em posições aleatórias
* Garantir distância mínima entre eles
* Associar um Youkai a cada ghost

👉 Atua como **sistema de geração procedural**

---

## ⚔️ `scripts/screens/battle/battle.gd`

Controla o sistema de combate.

### Funcionalidades:

* Interface criada via código
* Sistema de turnos
* Cálculo de dano aleatório
* Ações:

  * Atacar
  * Fugir

👉 Atua como **motor de combate**

---

## 🧱 `scenes/main/main.tscn`

Cena principal do jogo.

Contém:

* Player
* Spawner
* Chão (mapa)
* Ambiente

👉 Ponto de entrada do jogo

---

## 👤 `scenes/player/player.tscn`

Cena do jogador.

Contém:

* CharacterBody3D
* Camera3D
* Colisão

---

## 👻 `scenes/ghosts/ghost.tscn`

Cena base dos fantasmas.

Contém:

* Mesh visual
* Área de detecção (Area3D)
* Colisão

---

## ⚔️ `scenes/battle.tscn`

Cena da batalha.

Contém:

* Node Control
* Interface gerada dinamicamente

---

# 🔁 6. Fluxo de Execução

```text
Jogo inicia
   ↓
Main.tscn carrega
   ↓
Spawner cria fantasmas
   ↓
Player se movimenta
   ↓
Colisão com ghost
   ↓
Ghost dispara batalha
   ↓
Battle.tscn instanciada
   ↓
Combate ocorre
   ↓
Fim da batalha
```

---

# ▶️ 7. Como Executar o Projeto

---

## 🔧 Requisitos

* Godot Engine 4.x
* Projeto configurado no editor

---

## ▶️ Execução

1. Abrir o projeto no Godot
2. Definir `main.tscn` como cena principal
3. Executar o projeto (F5)

---

## 🎮 Controles (PC)

| Ação         | Tecla |
| ------------ | ----- |
| Andar frente | W     |
| Andar trás   | S     |
| Esquerda     | A     |
| Direita      | D     |
| Olhar        | Mouse |

---

## 📱 Mobile (planejado)

* Inclinar celular → movimento
* Girar celular → câmera

---

# 🧪 8. Estado Atual do Projeto

### ✔ Funcional

* Movimentação do jogador (PC)
* Spawn de fantasmas
* Detecção de colisão
* Sistema de batalha básico
* Estrutura modular

---

### ⚠ Em desenvolvimento

* Navegação real via sensores
* Interface aprimorada
* Sistema de negociação/puzzle
* Áudio e feedback visual
* Mapeamento de ambiente real

---

# 🧩 9. Considerações de Engenharia

O projeto aplica conceitos de:

* **Modularidade**
* **Separação de responsabilidades**
* **Reuso de componentes (Resources)**
* **Eventos e sinais (Godot)**
* **Programação orientada a objetos**

---

# 🚀 10. Próximos Passos

* Implementar UI mais robusta
* Adicionar efeitos visuais
* Melhorar combate (estratégia)
* Integrar sensores reais
* Testes em dispositivo Android

---

# 📌 Conclusão

Rukongai propõe uma experiência diferenciada ao unir:

* Mecânicas físicas reais
* Exploração virtual
* Narrativa sobrenatural

O projeto ainda está em fase inicial, mas já apresenta uma base sólida para evolução.


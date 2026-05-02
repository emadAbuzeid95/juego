## ComboManager - Gestiona la lógica de combos del juego.
## Controla qué colores debe atrapar el jugador y evalúa si los hits son correctos.
class_name ComboManager
extends Node

var combo_target: Array[Color] = []
var combo_progress: Array[Color] = []

var _parent: Node
var _spawner: Spawner
var _ui: UIController

## Constantes para el resultado de un hit
## Ver [check_hit] para saber qué significa cada valor
const HIT_NEUTRAL := 0
const HIT_MATCH := 1
const HIT_MISS := 2

## Configura las dependencias del ComboManager.
## [param parent] Nodo padre (main.gd)
## [param spawner] Referencia al Spawner para generar combos
## [param ui] Referencia al UIController para actualizar la UI
func setup(parent: Node, spawner: Spawner, ui: UIController) -> void:
	_parent = parent
	_spawner = spawner
	_ui = ui

## Genera un nuevo combo objetivo aleatorio.
## Elige colores aleatorios y actualiza la UI con los slots del combo.
func generate_new_combo() -> void:
	clear_progress()
	combo_target.clear()
	for i in range(Config.COMBO_SIZE):
		combo_target.append(_spawner.get_color_by_index(randi() % Config.COLOR_PIECE.size()))
	_ui.burn_and_update_slots(combo_target)

## Evalúa si un color atrapado es parte del combo o no.
## Compara el color atrapado con el siguiente color esperado del combo.
## [param caught_color] Color de la pieza que fue atrapada
## Retorna: [HIT_MATCH] si completó el combo, [HIT_MISS] si se equivocó, [HIT_NEUTRAL] si sigue en progreso
func check_hit(caught_color: Color) -> int:
	# Guard: si el combo ya está completo, no hay nada que evaluar
	if combo_progress.size() >= Config.COMBO_SIZE:
		return HIT_NEUTRAL
	if combo_progress.size() < Config.COMBO_SIZE and caught_color == combo_target[combo_progress.size()]:
		combo_progress.append(caught_color)
		if combo_progress.size() == Config.COMBO_SIZE:
			return HIT_MATCH
		return HIT_NEUTRAL
	elif combo_progress.size() > 0 and caught_color != combo_target[combo_progress.size()]:
		return HIT_MISS
	return HIT_NEUTRAL

## Limpia el progreso actual del combo.
## Se llama cuando se completa un combo o cuando el jugador falla.
func clear_progress() -> void:
	combo_progress.clear()

## Obtiene la penalización por fallar un combo.
## Retorna: Cantidad de puntos a restar (tamaño del progreso actual)
func get_penalty() -> int:
	return combo_progress.size()

## Calcula el bonus por completar un combo.
## Retorna: Puntos bonus aleatorios entre 3 y 10
func get_bonus() -> int:
	return randi() % 8 + 3
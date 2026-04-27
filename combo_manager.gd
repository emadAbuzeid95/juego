class_name ComboManager
extends Node

var combo_target: Array[Color] = []
var combo_progress: Array[Color] = []

var _parent: Node
var _spawner: Spawner
var _ui: UIController

const HIT_NEUTRAL := 0
const HIT_MATCH := 1
const HIT_MISS := 2

func setup(parent: Node, spawner: Spawner, ui: UIController) -> void:
	_parent = parent
	_spawner = spawner
	_ui = ui

func generate_new_combo() -> void:
	combo_target.clear()
	for i in range(Config.COMBO_SIZE):
		combo_target.append(_spawner.get_color_by_index(randi() % Config.COLOR_PIECE.size()))
	_ui.update_combo_target(combo_target)
	_ui.burn_and_update_slots()

func check_hit(caught_color: Color) -> int:
	if combo_progress.size() < Config.COMBO_SIZE and caught_color == combo_target[combo_progress.size()]:
		combo_progress.append(caught_color)
		if combo_progress.size() == Config.COMBO_SIZE:
			return HIT_MATCH
		return HIT_NEUTRAL
	elif combo_progress.size() > 0 and caught_color != combo_target[combo_progress.size()]:
		return HIT_MISS
	return HIT_NEUTRAL

func clear_progress() -> void:
	combo_progress.clear()

func get_penalty() -> int:
	return combo_progress.size()

func get_bonus() -> int:
	return randi() % 8 + 3
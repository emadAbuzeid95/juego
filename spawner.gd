class_name Spawner
extends Node

var parent_node: Node2D

func _init(parent: Node2D) -> void:
	parent_node = parent

func spawn_pieza() -> Pieza:
	var rect := ColorRect.new()
	rect.size = Vector2(Config.PIECE_SIZE, Config.PIECE_SIZE)
	var col: int = randi() % Config.COLS
	rect.position = Vector2(get_col_x(col) - Config.PIECE_SIZE / 2, Config.SPAWN_Y)
	var color := get_random_color()
	rect.color = color
	parent_node.add_child(rect)

	return Pieza.new(rect, color)

func get_col_x(col: int) -> float:
	return Config.COL_START_X + col * Config.COL_WIDTH

func get_random_color() -> Color:
	return Color(Config.COLOR_PIECE[randi() % Config.COLOR_PIECE.size()])

func get_color_by_index(index: int) -> Color:
	return Color(Config.COLOR_PIECE[index])
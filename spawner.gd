## Spawner - Genera piezas que caen desde arriba.
## Se encarga de crear las piezas en columnas aleatorias con colores aleatorios.
class_name Spawner
extends Node

var parent_node: Node2D

## Constructor del Spawner
## [param parent] Nodo padre donde se agregan las piezas
func _init(parent: Node2D) -> void:
	parent_node = parent

## Crea y devuelve una nueva Pieza en una columna aleatoria.
## La pieza aparece en la parte superior de la pantalla y baja.
## Retorna: Una nueva instancia de [Pieza]
func spawn_pieza() -> Pieza:
	var rect := ColorRect.new()
	rect.size = Vector2(Config.PIECE_SIZE, Config.PIECE_SIZE)
	var col: int = randi() % Config.COLS
	rect.position = Vector2(get_col_x(col) - Config.PIECE_SIZE / 2, Config.SPAWN_Y)
	var color := get_random_color()
	rect.color = color
	parent_node.add_child(rect)

	return Pieza.new(rect, color)

## Calcula la posición X del centro de una columna.
## [param col] Índice de la columna (0-3)
## Retorna: Posición X del centro de la columna
func get_col_x(col: int) -> float:
	return Config.COL_START_X + col * Config.COL_WIDTH

## Obtiene un color aleatorio de los disponibles.
## Retorna: Color aleatorio de [Config.COLOR_PIECE]
func get_random_color() -> Color:
	return Color(Config.COLOR_PIECE[randi() % Config.COLOR_PIECE.size()])

## Obtiene el color en un índice específico.
## [param index] Índice del color en la lista de colores
## Retorna: Color en el índice especificado
func get_color_by_index(index: int) -> Color:
	return Color(Config.COLOR_PIECE[index])
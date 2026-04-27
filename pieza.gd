## Clase Pieza
## Representa una pieza que cae en el juego.
## Contiene el ColorRect visual y su color asociado.
class_name Pieza
extends RefCounted

var rect: ColorRect
var color: Color

## Constructor de Pieza
## [param rect_] ColorRect visual de la pieza
## [param color_] Color de la pieza
func _init(rect_: ColorRect, color_: Color) -> void:
	rect = rect_
	color = color_
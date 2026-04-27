class_name Pieza
extends RefCounted

var rect: ColorRect
var color: Color

func _init(rect_: ColorRect, color_: Color) -> void:
	rect = rect_
	color = color_
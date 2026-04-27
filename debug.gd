## Debug - Utilidad para logging condicional.
## Usa print() solo cuando ENABLED es true. Para activar/desactivar, cambiar el flag abajo.
class_name Debug
extends Node

## Flag para activar/desactivar logs. Cambiar a true para ver logs, false para silenciar.
const ENABLED: bool = false

## Imprime un mensaje solo si ENABLED es true.
## [param msg] Mensaje a imprimir en consola
static func log(msg: String) -> void:
	if ENABLED:
		print("[DEBUG] ", msg)
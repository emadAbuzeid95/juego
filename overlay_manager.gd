## OverlayManager - Maneja las pantallas de Game Over y Level Complete.
## Crea paneles semitransparentes con etiquetas y botones.
class_name OverlayManager
extends Node

var _parent: Node
var _restart_callback: Callable

## Configura el nodo padre para los overlays.
## [param parent] Nodo padre donde se agregan los paneles
func setup(parent: Node) -> void:
	_parent = parent

## Muestra la pantalla de Game Over.
## Pausa el juego y muestra puntuación final con botón "Reintentar".
## [param final_score] Puntuación final del jugador
## [param on_restart] Callable que se ejecuta al presionar "Reintentar"
func show_game_over_screen(final_score: int, on_restart: Callable) -> void:
	_restart_callback = on_restart
	_parent.get_tree().paused = true

	var panel := ColorRect.new()
	panel.name = "GameOverPanel"
	panel.position = Vector2(0, 0)
	panel.size = Vector2(640, 720)
	panel.color = Color(0, 0, 0, 0.85)
	panel.z_index = 100
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	_parent.add_child(panel)

	var label := Label.new()
	label.text = "GAME OVER"
	label.position = Vector2(220, 250)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 48)
	panel.add_child(label)

	var score_lbl := Label.new()
	score_lbl.text = "Score final: " + str(final_score)
	score_lbl.position = Vector2(240, 320)
	score_lbl.add_theme_color_override("font_color", Color(1, 0.5, 0.5))
	score_lbl.add_theme_font_size_override("font_size", 28)
	panel.add_child(score_lbl)

	var button := Button.new()
	button.text = "Reintentar"
	button.position = Vector2(250, 400)
	button.size = Vector2(140, 50)
	button.add_theme_font_size_override("font_size", 20)
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.pressed.connect(_on_restart_pressed.bind(panel))
	panel.add_child(button)

## Muestra la pantalla de Nivel Completado.
## Pausa el juego y muestra mensaje de éxito con botón "Continuar".
## Actualmente no hace nada al presionar continuar (solo desapila).
func show_level_complete_screen() -> void:
	_parent.get_tree().paused = true

	var panel := ColorRect.new()
	panel.name = "LevelCompletePanel"
	panel.position = Vector2(0, 0)
	panel.size = Vector2(640, 720)
	panel.color = Color(0, 0, 0, 0.85)
	panel.z_index = 100
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	_parent.add_child(panel)

	var label := Label.new()
	label.text = "LEVEL 1 COMPLETE!"
	label.position = Vector2(160, 250)
	label.add_theme_color_override("font_color", Color.GREEN)
	label.add_theme_font_size_override("font_size", 42)
	panel.add_child(label)

	var button := Button.new()
	button.text = "Continuar"
	button.position = Vector2(250, 380)
	button.size = Vector2(140, 50)
	button.add_theme_font_size_override("font_size", 20)
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.pressed.connect(_on_continue_pressed.bind(panel))
	panel.add_child(button)

## Callback interno cuando se presiona "Reintentar".
## Despausa el juego, elimina el panel y ejecuta el callback de restart.
## [param panel] Panel a eliminar
func _on_restart_pressed(panel: ColorRect) -> void:
	_parent.get_tree().paused = false
	panel.queue_free()
	if _restart_callback.is_valid():
		_restart_callback.call()

## Callback interno cuando se presiona "Continuar".
## Despausa el juego y elimina el panel.
## [param panel] Panel a eliminar
func _on_continue_pressed(panel: ColorRect) -> void:
	_parent.get_tree().paused = false
	panel.queue_free()
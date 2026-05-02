## UIController - Controlador de interfaz de usuario.
## Maneja todo lo relacionado con la UI: puntuación, combos, barra de progreso y texto flotante.
class_name UIController
extends Node

var parent: Node2D
var score_label: Label
var combo_label: Label
var progress_bar: ColorRect
var progress_label: Label

var combo_target: Array[Color]
var combo_progress: Array[Color]

## Constructor del UIController
## [param parent_node] Nodo padre donde se crean los elementos de UI
func _init(parent_node: Node2D) -> void:
	parent = parent_node

## Configura las referencias a los nodos de UI de la escena.
## [param score_lbl] Label que muestra la puntuación
## [param combo_lbl] Label que muestra el estado del combo
## [param progress] ColorRect que representa la barra de progreso
## [param progress_lbl] Label que muestra "score/target"
func setup(
	score_lbl: Label,
	combo_lbl: Label,
	progress: ColorRect,
	progress_lbl: Label
) -> void:
	score_label = score_lbl
	combo_label = combo_lbl
	progress_bar = progress
	progress_label = progress_lbl
	combo_target = []
	combo_progress = []

## === FLOATING TEXT ===
## Muestra texto que flota y sube desde una posición, luego desaparece.
## Se usa para mostrar +1, -1, bonus, etc.
## [param pos] Posición inicial del texto
## [param amount] Cantidad a mostrar (positivos en verde, negativos en rojo)
func show_floating_text(pos: Vector2, amount: int) -> void:
	var label := Label.new()
	label.text = "+" + str(amount) if amount > 0 else str(amount)
	label.position = pos + Vector2(-20, -60)
	label.add_theme_color_override("font_color", Color.GREEN if amount > 0 else Color.RED)
	label.add_theme_font_size_override("font_size", 24)
	parent.add_child(label)

	var tween := parent.create_tween()
	tween.tween_property(label, "position:y", pos.y - 120, 0.8)
	tween.tween_callback(label.queue_free)

## === PROGRESS BAR ===
## Actualiza la barra de progreso basada en la puntuación actual.
## La barra crece de abajo hacia arriba según el score vs target.
## [param score] Puntuación actual del jugador
func update_progress_bar(score: int) -> void:
	var fill_height: float = clamp(float(score) * 400.0 / float(Config.PROGRESS_TARGET), 0.0, 400.0)
	progress_bar.offset_top = 510.0 - fill_height
	progress_bar.offset_bottom = 515.0
	progress_label.text = str(score) + "/" + str(Config.PROGRESS_TARGET)

## Actualiza el texto del label de puntuación.
## [param score] Puntuación actual
func update_score_label(score: int) -> void:
	score_label.text = "Score: " + str(score)

## === LANE MARKERS ===
## Dibuja líneas verticales marcando los límites del área de juego.
## Ayudan al jugador a visualizar las columnas.
func draw_lane_markers() -> void:
	var left_boundary := Config.COL_START_X - Config.PLAYER_SIZE / 2
	var right_boundary := Config.COL_START_X + Config.COLS * Config.COL_WIDTH - Config.PLAYER_SIZE / 2

	var left_marker := ColorRect.new()
	left_marker.size = Vector2(4, 720)
	left_marker.color = Color(1, 1, 1, 0.3)
	left_marker.position = Vector2(left_boundary - 20, 0)
	parent.add_child(left_marker)

	var right_marker := ColorRect.new()
	right_marker.size = Vector2(4, 720)
	right_marker.color = Color(1, 1, 1, 0.3)
	right_marker.position = Vector2(right_boundary + 20, 0)
	parent.add_child(right_marker)

## === COMBO ===
## Crea una textura circular de un color específico.
## Se usa para mostrar los colores objetivo del combo en los slots.
## [param color] Color de la textura
## [param size] Tamaño en píxeles (default 30)
## Retorna: ImageTexture con un círculo del color especificado
func create_circle_texture(color: Color, size: int = 30) -> ImageTexture:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var center := size / 2.0
	var radius := size / 2.0 - 2
	for x in range(size):
		for y in range(size):
			var dist := sqrt((x - center) * (x - center) + (y - center) * (y - center))
			if dist <= radius:
				image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)

## Actualiza los slots del combo con los nuevos colores objetivo.
## [param new_target] Array de colores que forman el nuevo combo
func update_combo_target(new_target: Array[Color]) -> void:
	combo_target = new_target

## Quema los slots antiguos (animación de shrinks) y muestra los nuevos.
## Se llama cuando se completa un combo o se genera uno nuevo.
func burn_and_update_slots() -> void:
	for i in range(Config.COMBO_SIZE):
		var slot: TextureRect = parent.get_node("UI/ComboSlot" + str(i))
		slot.modulate = Color(0.15, 0.15, 0.15, 1)
		slot.scale = Vector2(0.5, 0.5)

	await parent.get_tree().create_timer(0.2).timeout

	for i in range(Config.COMBO_SIZE):
		var slot: TextureRect = parent.get_node("UI/ComboSlot" + str(i))
		slot.texture = create_circle_texture(combo_target[i], 30)
		slot.modulate = Color.WHITE
		var tween := parent.create_tween()
		tween.tween_property(slot, "scale", Vector2(1.0, 1.0), 0.15)

## Produce un pulso visual en el label del combo (subida + bajada + color amarillo).
## Se llama cuando el jugador completa un combo válido.
func pulse_combo_label() -> void:
	var tween := parent.create_tween()
	tween.tween_property(combo_label, "scale", Vector2(1.5, 1.5), 0.1)
	tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.1)
	combo_label.modulate = Color.YELLOW
	var timer := Timer.new()
	timer.wait_time = 0.3
	timer.one_shot = true
	timer.timeout.connect(func():
		combo_label.modulate = Color.WHITE
	)
	parent.add_child(timer)
	timer.start()
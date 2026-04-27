extends Node2D

# === CONFIG ===
const COLS: int = 4
const COL_WIDTH: int = 80
const COL_START_X: int = 200
const SPAWN_Y: int = -50
const CATCH_Y: int = 620
const PLAYER_SIZE: int = 80
const PIECE_SIZE: int = 80
const COMBO_SIZE: int = 3

# === COLORS ===
const COLOR_PIECE = ["#e94560", "#0f3460", "#16c79a", "#f7b731"]
const COLOR_EMPTY: Color = Color(0.3, 0.3, 0.3)

# === STATE ===
var piezas: Array[Pieza] = []
var score: int = 0
var velocidad_caida: float = 250.0
var tiempo_spawn: float = 1.5
var tiempo_actual: float = 0.0
var combo_target: Array[Color] = []
var combo_progress: Array[Color] = []

# === NODES ===
@onready var score_label: Label = $UI/ScoreLabel
@onready var combo_label: Label = $UI/ComboLabel

# === CLASSES ===
class Pieza:
	var rect: ColorRect
	var color: Color

	func _init(rect_: ColorRect, color_: Color):
		rect = rect_
		color = color_

# === LIFECYCLE ===
func _ready() -> void:
	randomize()
	score_label.text = "Score: 0"
	generate_new_combo()
	draw_lane_markers()

func _process(delta: float) -> void:
	tiempo_actual += delta
	if tiempo_actual >= tiempo_spawn:
		tiempo_actual = 0.0
		spawn_pieza()
	update_piezas(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			var click_pos := mouse_event.position
			check_pieza_click(click_pos)

# === GAME LOGIC ===
func update_piezas(delta: float) -> void:
	for i in range(piezas.size() - 1, -1, -1):
		var pieza: Pieza = piezas[i]
		pieza.rect.position.y += velocidad_caida * delta

		if pieza.rect.position.y > CATCH_Y + 80:
			pieza.rect.queue_free()
			piezas.remove_at(i)

func check_pieza_click(click_pos: Vector2) -> void:
	for i in range(piezas.size() - 1, -1, -1):
		var pieza: Pieza = piezas[i]
		var pieza_bounds := Rect2(
			pieza.rect.position.x,
			pieza.rect.position.y,
			PIECE_SIZE,
			PIECE_SIZE
		)
		if pieza_bounds.has_point(click_pos):
			handle_pieza_caught(pieza, i, click_pos)
			return

func handle_pieza_caught(pieza: Pieza, index: int, click_pos: Vector2) -> void:
	var caught_color: Color = pieza.color
	var pos: Vector2 = pieza.rect.position
	pieza.rect.queue_free()
	piezas.remove_at(index)

	explode(pos, caught_color)

	score += 1
	var bonus: int = 0

	if combo_progress.size() < COMBO_SIZE and caught_color == combo_target[combo_progress.size()]:
		combo_progress.append(caught_color)
		if combo_progress.size() == COMBO_SIZE:
			bonus = randi() % 8 + 3
			score += bonus
			combo_progress.clear()
			generate_new_combo()
			pulse_combo_label()
	elif combo_progress.size() > 0 and caught_color != combo_target[combo_progress.size()]:
		var penalty: int = combo_progress.size()
		score -= penalty
		combo_progress.clear()
		show_floating_text(click_pos, -penalty)
	else:
		show_floating_text(click_pos, 1)

	if bonus > 0:
		show_floating_text(click_pos, bonus)

	score_label.text = "Score: " + str(score)

func spawn_pieza() -> void:
	var rect := ColorRect.new()
	rect.size = Vector2(PIECE_SIZE, PIECE_SIZE)
	var col: int = randi() % COLS
	rect.position = Vector2(get_col_x(col) - PIECE_SIZE / 2, SPAWN_Y)
	var color := get_random_color()
	rect.color = color
	add_child(rect)

	piezas.append(Pieza.new(rect, color))

# === HELPERS ===
func get_col_x(col: int) -> float:
	return COL_START_X + col * COL_WIDTH

# === COMBO ===
func generate_new_combo() -> void:
	combo_target.clear()
	for i in range(COMBO_SIZE):
		combo_target.append(get_color_by_index(randi() % COLOR_PIECE.size()))
	burn_and_update_slots()

func burn_and_update_slots() -> void:
	for i in range(COMBO_SIZE):
		var slot: TextureRect = $UI.get_node("ComboSlot" + str(i))
		slot.modulate = Color(0.15, 0.15, 0.15, 1)
		slot.scale = Vector2(0.5, 0.5)

	await get_tree().create_timer(0.2).timeout

	for i in range(COMBO_SIZE):
		var slot: TextureRect = $UI.get_node("ComboSlot" + str(i))
		slot.texture = create_circle_texture(combo_target[i], 30)
		slot.modulate = Color.WHITE
		var tween := create_tween()
		tween.tween_property(slot, "scale", Vector2(1.0, 1.0), 0.15)

func update_combo_ui() -> void:
	for i in range(COMBO_SIZE):
		var slot: TextureRect = $UI.get_node("ComboSlot" + str(i))
		slot.modulate = Color.WHITE
		slot.texture = create_circle_texture(combo_target[i], 30)
		slot.scale = Vector2(1.0, 1.0)

func pulse_combo_label() -> void:
	var tween := create_tween()
	tween.tween_property(combo_label, "scale", Vector2(1.5, 1.5), 0.1)
	tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.1)
	combo_label.modulate = Color.YELLOW
	var timer := Timer.new()
	timer.wait_time = 0.3
	timer.one_shot = true
	timer.timeout.connect(func():
		combo_label.modulate = Color.WHITE
	)
	add_child(timer)
	timer.start()

func get_color_by_index(index: int) -> Color:
	return Color(COLOR_PIECE[index])

func get_random_color() -> Color:
	return Color(COLOR_PIECE[randi() % COLOR_PIECE.size()])

# === UI ===
func show_floating_text(pos: Vector2, amount: int) -> void:
	var label := Label.new()
	label.text = "+" + str(amount) if amount > 0 else str(amount)
	label.position = pos + Vector2(-20, -60)
	label.add_theme_color_override("font_color", Color.GREEN if amount > 0 else Color.RED)
	label.add_theme_font_size_override("font_size", 24)
	add_child(label)

	var tween := create_tween()
	tween.tween_property(label, "position:y", pos.y - 120, 0.8)
	tween.tween_callback(label.queue_free)

func draw_lane_markers() -> void:
	var left_boundary := COL_START_X - PLAYER_SIZE / 2
	var right_boundary := COL_START_X + COLS * COL_WIDTH - PLAYER_SIZE / 2

	var left_marker := ColorRect.new()
	left_marker.size = Vector2(4, 720)
	left_marker.color = Color(1, 1, 1, 0.3)
	left_marker.position = Vector2(left_boundary - 20, 0)
	add_child(left_marker)

	var right_marker := ColorRect.new()
	right_marker.size = Vector2(4, 720)
	right_marker.color = Color(1, 1, 1, 0.3)
	right_marker.position = Vector2(right_boundary + 20, 0)
	add_child(right_marker)

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

func explode(pos: Vector2, color: Color) -> void:
	var particles := GPUParticles2D.new()
	particles.position = pos + Vector2(40, 40)
	particles.amount = 12
	particles.lifetime = 0.4
	particles.local_coords = true

	var spread := CircleShape2D.new()
	spread.radius = 5.0

	var process_material := ParticleProcessMaterial.new()
	process_material.direction = Vector3.RIGHT
	process_material.spread = 360.0
	process_material.initial_velocity_min = 150.0
	process_material.initial_velocity_max = 250.0
	process_material.gravity = Vector3(0, 400, 0)
	process_material.scale_max = 2.0
	process_material.scale_min = 1.0
	process_material.color = color

	particles.process_material = process_material
	add_child(particles)
	particles.restart()
	particles.emitting = true

	var timer := Timer.new()
	timer.wait_time = 0.5
	timer.one_shot = true
	timer.timeout.connect(func(): particles.queue_free())
	add_child(timer)
	timer.start()
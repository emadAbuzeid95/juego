extends Node2D

# === STATE ===
var piezas: Array[Pieza] = []
var score: int = 0
var velocidad_caida: float = 250.0
var tiempo_spawn: float = 1.5
var tiempo_actual: float = 0.0
var tiempo_juego: float = 0.0
var combo_target: Array[Color] = []
var combo_progress: Array[Color] = []

# === NODES ===
@onready var score_label: Label = $UI/ScoreLabel
@onready var combo_label: Label = $UI/ComboLabel
@onready var progress_bar: ColorRect = $UI/ProgressBarFill
@onready var progress_label: Label = $UI/ProgressLabel

var spawner: Spawner
var ui: UIController

# === LIFECYCLE ===
func _ready() -> void:
	randomize()
	spawner = Spawner.new(self)
	ui = UIController.new(self)
	ui.setup(score_label, combo_label, progress_bar, progress_label)
	score_label.text = "Score: 0"
	generate_new_combo()
	ui.draw_lane_markers()

func _process(delta: float) -> void:
	tiempo_actual += delta
	tiempo_juego += delta

	velocidad_caida = 250.0 + (tiempo_juego * 5.0)
	tiempo_spawn = max(0.5, 1.5 - (tiempo_juego * 0.02))

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

		if pieza.rect.position.y > Config.CATCH_Y + 80:
			var last_pos := pieza.rect.position + Vector2(Config.PIECE_SIZE / 2, Config.PIECE_SIZE / 2)
			pieza.rect.queue_free()
			piezas.remove_at(i)
			score -= 1
			ui.show_floating_text(last_pos, -1)
			ui.update_score_label(score)
			update_progress_bar()
			if score < 0:
				game_over()

func check_pieza_click(click_pos: Vector2) -> void:
	for i in range(piezas.size() - 1, -1, -1):
		var pieza: Pieza = piezas[i]
		var pieza_bounds := Rect2(
			pieza.rect.position.x,
			pieza.rect.position.y,
			Config.PIECE_SIZE,
			Config.PIECE_SIZE
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

	if combo_progress.size() < Config.COMBO_SIZE and caught_color == combo_target[combo_progress.size()]:
		combo_progress.append(caught_color)
		if combo_progress.size() == Config.COMBO_SIZE:
			bonus = randi() % 8 + 3
			score += bonus
			combo_progress.clear()
			generate_new_combo()
			ui.pulse_combo_label()
	elif combo_progress.size() > 0 and caught_color != combo_target[combo_progress.size()]:
		var penalty: int = combo_progress.size()
		score -= penalty
		combo_progress.clear()
		ui.show_floating_text(click_pos, -penalty)
	else:
		ui.show_floating_text(click_pos, 1)

	if bonus > 0:
		ui.show_floating_text(click_pos, bonus)

	ui.update_score_label(score)
	update_progress_bar()

func spawn_pieza() -> void:
	var nueva_pieza: Pieza = spawner.spawn_pieza()
	piezas.append(nueva_pieza)

# === HELPERS ===

# === COMBO ===
func generate_new_combo() -> void:
	combo_target.clear()
	for i in range(Config.COMBO_SIZE):
		combo_target.append(spawner.get_color_by_index(randi() % Config.COLOR_PIECE.size()))
	ui.update_combo_target(combo_target)
	ui.burn_and_update_slots()

# === UI ===
func update_progress_bar() -> void:
	ui.update_progress_bar(score)
	print("Score: ", score, " | Target: ", Config.PROGRESS_TARGET, " | Condición: ", score >= Config.PROGRESS_TARGET)

	if score >= Config.PROGRESS_TARGET:
		progress_label.text = "COMPLETE!"
		show_level_complete_screen()

func show_level_complete_screen() -> void:
	print("==== LEVEL COMPLETE TRIGGERED ====")
	get_tree().paused = true

	var panel := ColorRect.new()
	panel.name = "LevelCompletePanel"
	panel.position = Vector2(0, 0)
	panel.size = Vector2(640, 720)
	panel.color = Color(0, 0, 0, 0.85)
	panel.z_index = 100
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(panel)

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
	button.pressed.connect(func():
		get_tree().paused = false
		panel.queue_free()
	)
	panel.add_child(button)

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

# === GAME OVER ===
func game_over() -> void:
	get_tree().paused = true

	var panel := ColorRect.new()
	panel.name = "GameOverPanel"
	panel.position = Vector2(0, 0)
	panel.size = Vector2(640, 720)
	panel.color = Color(0, 0, 0, 0.85)
	panel.z_index = 100
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(panel)

	var label := Label.new()
	label.text = "GAME OVER"
	label.position = Vector2(220, 250)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 48)
	panel.add_child(label)

	var score_lbl := Label.new()
	score_lbl.text = "Score final: " + str(score)
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
	button.pressed.connect(func():
		get_tree().paused = false
		restart_game()
	)
	panel.add_child(button)

func restart_game() -> void:
	for pieza in piezas:
		pieza.rect.queue_free()
	piezas.clear()

	score = 0
	combo_target.clear()
	combo_progress.clear()

	score_label.text = "Score: 0"
	generate_new_combo()

	var panel := get_node_or_null("GameOverPanel")
	if panel:
		panel.queue_free()
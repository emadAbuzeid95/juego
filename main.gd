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
var effects
var overlay

const _EffectsScript = preload("res://effects.gd")
const _OverlayScript = preload("res://overlay_manager.gd")

# === LIFECYCLE ===
func _ready() -> void:
	randomize()
	spawner = Spawner.new(self)
	ui = UIController.new(self)
	effects = _EffectsScript.new()
	effects.setup(self)
	overlay = _OverlayScript.new()
	overlay.setup(self)
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
				overlay.show_game_over_screen(score, restart_game)

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

	effects.explode(pos, caught_color)

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
		overlay.show_level_complete_screen()

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
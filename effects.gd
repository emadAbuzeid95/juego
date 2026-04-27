## Effects - Sistema de partículas y efectos visuales.
## Se encarga de crear explosiones de partículas cuando el jugador atrapa una pieza.
class_name Effects
extends Node

var _parent: Node

## Configura el padre para agregar las partículas como hijos.
## [param parent] Nodo padre donde se instancian las partículas
func setup(parent: Node) -> void:
	_parent = parent

## Crea una explosión de partículas en la posición dada con el color especificado.
## Las partículas se expanden en 360° y desaparecen después de 0.5 segundos.
## [param pos] Posición donde ocurre la explosión (se le suma un offset para centrar)
## [param color] Color de las partículas
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
	_parent.add_child(particles)
	particles.restart()
	particles.emitting = true

	var timer := Timer.new()
	timer.wait_time = 0.5
	timer.one_shot = true
	timer.timeout.connect(func(): particles.queue_free())
	_parent.add_child(timer)
	timer.start()
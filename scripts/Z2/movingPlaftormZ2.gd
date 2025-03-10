extends Node2D  # Ajusta esto según el tipo de nodo que estés usando

# Configuración de movimiento
@export var speed: float = 100.0     # Velocidad de movimiento en píxeles/segundo
@export var max_distance: float = 750.0  # Distancia máxima que puede moverse hacia abajo
@export var smooth_movement: bool = true  # Si es true, el movimiento será suave

# Variables de seguimiento
var initial_position: Vector2
var target_position: Vector2
var has_started_moving: bool = false

func _ready() -> void:
	# Guarda la posición inicial
	initial_position = position
	# Calcula la posición objetivo
	target_position = Vector2(position.x, position.y + max_distance)

func _process(delta: float) -> void:
	if Global.isLeverOn:
		if not has_started_moving:
			has_started_moving = true
			
		if smooth_movement:
			# Movimiento suave hacia la posición objetivo
			position = position.move_toward(target_position, speed * delta)
		else:
			# Movimiento directo hacia abajo
			position.y += speed * delta
			
			# Asegúrate de no pasar la distancia máxima
			if position.y >= initial_position.y + max_distance:
				position.y = initial_position.y + max_distance
	else:
		# Si quieres que el nodo vuelva a su posición original cuando la palanca está desactivada
		# descomenta estas líneas:
		if has_started_moving:
			Global.isLeverActivable = 0
			if smooth_movement:
				position = position.move_toward(initial_position, speed * delta)
			else:
				position.y -= speed * delta
		if position.y <= initial_position.y:
			position.y = initial_position.y
			Global.isLeverActivable = 1
			has_started_moving = false
			
	#Llega a la posiicon maxima 
	if position.y == initial_position.y + max_distance:
		Global.isLeverActivable = 1
	
	if Global.restartPlatform == 1:
		position = initial_position
		Global.restartPlatform = 0
	

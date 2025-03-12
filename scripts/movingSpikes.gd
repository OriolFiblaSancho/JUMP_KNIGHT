extends CharacterBody2D

@export var pos: Vector2
@export var vel: float

@onready var particlesLeft = $left/Particles
@onready var particlesRight = $right/Particles
@onready var particlesUp = $up/Particles
@onready var particlesDown = $down/Particles
func _ready() -> void:

	#Controla la animacion de girar
	var rotate_tween = get_tree().create_tween()
	rotate_tween.set_loops()
	rotate_tween.tween_property($Sprite2D, "rotation", deg_to_rad(360), 0.5).as_relative()
	
	var move_tween = get_tree().create_tween()
	# Hacemos que los tweens se repitan sin acumulación
	move_tween.set_loops()\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_CUBIC)
	# Guardamos la posición inicial para que no se acumule el desplazamiento
	var start_position = position
	var target_position = start_position + pos

	# Movimiento de ida y vuelta sin acumulación de posición
	move_tween.tween_property(self, "position", target_position, vel)
	move_tween.tween_property(self, "position", start_position, vel)

func _process(delta: float) -> void:
	if !$spinningBlade.is_playing():
		$spinningBlade.play()

func _on_left_area_entered(area: Area2D) -> void:
	if area.name == "attackArea":
			particlesLeft.emitting = true
		
func _on_right_area_entered(area: Area2D) -> void:
	if area.name == "attackArea":
		particlesRight.emitting = true


func _on_up_area_entered(area: Area2D) -> void:
	if area.name == "attackArea":
		particlesUp.emitting = true


func _on_down_area_entered(area: Area2D) -> void:
	if area.name == "attackArea":
		particlesDown.emitting = true

extends AnimatableBody2D

@export var pos: Vector2
@export var vel: float


func _ready() -> void:
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

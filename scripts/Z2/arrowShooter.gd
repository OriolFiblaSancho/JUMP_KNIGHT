extends Node2D

@export var arrow_scene: PackedScene = null
@export var player: Node2D 

var spawn_range_x: float = 700  # Range were the arrows can be spawn
var extra_height_variation: float = 200  # Variation of the height were the arow can spawn

func _ready():
	$Timer.wait_time = 0.2
	$Timer.start()
	

func _on_timer_timeout():
	position.y = player.position.y - 1000
	# Generates random position X close to the player
	var spawn_x = randf_range(player.global_position.x - spawn_range_x, player.global_position.x + spawn_range_x)
	# Change Y spawn for the arrow
	var spawn_y = global_position.y + randf_range(-extra_height_variation, extra_height_variation)  

	var arrow = arrow_scene.instantiate()
	add_child(arrow)
	arrow.top_level = true
	arrow.global_position = Vector2(spawn_x, spawn_y)
	# Makes arrow aim to the player
	arrow.set_target(player.global_position)

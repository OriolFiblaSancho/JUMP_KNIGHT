extends RigidBody2D

var speed: float = 500
var gravity: float = 600
@onready var timer = $Timer  # Time for destruction

func _ready():
	#Give a random spawn pos to simulate someone is shooting you with a bow
	var direction = Vector2(randf_range(-0.3, 0.3), 1).normalized()
	linear_velocity = direction * speed

	timer.start()

func _physics_process(delta):
	linear_velocity.y += gravity * delta
	rotation = linear_velocity.angle()*0.5

func set_target(target_position: Vector2):
	# Direction to the player
	var direction = (target_position - global_position).normalized()
	linear_velocity = direction * speed

func _on_timer_timeout():
	#Makes arrow dissapear
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	queue_free()

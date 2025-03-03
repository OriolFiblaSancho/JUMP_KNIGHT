extends RigidBody2D

var speed: float = 300
var gravity: float = 600

@onready var damageAreaCol = $damageArea/CollisionPolygon2D
@onready var arrowCol = $CollisionShape2D

func _ready():
	#Give a random spawn pos to simulate someone is shooting you with a bow
	var direction = Vector2(randf_range(-0.3, 0.3), 1).normalized()
	linear_velocity = direction * speed
	
	damageAreaCol.disabled = false
	arrowCol.disabled = false

func _physics_process(delta):
	linear_velocity.y += gravity * delta

func set_target(target_position: Vector2):
	# Direction to the player
	var direction = (target_position - global_position).normalized()
	linear_velocity = direction * speed
	
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("floor"):
		damageAreaCol.disabled = true
		arrowCol.disabled = true
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.5)
		await tween.finished
		queue_free()

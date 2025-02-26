extends Node2D

@onready var arrow = $arrow
@onready var arrowSprite = $arrow/Arrow
@onready var arrowCol = $arrow/CollisionShape2D

@onready var arrowShooter = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	arrowSprite.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		arrow.position = arrowShooter.position
		arrowSprite.show()
		

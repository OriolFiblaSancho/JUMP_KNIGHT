extends StaticBody2D
@onready var col = $CollisionShape2D
@onready var sprite = $Sprite2D
var open = false

func _ready() -> void:
	col.disabled = false
	sprite.frame = 87

func _on_open_door_area_area_entered(area: Area2D) -> void:
	if area.name == "attackArea" and open == false:
		open = true
		$openound.play()
		col.set_deferred("disabled", true)
		sprite.frame = 88

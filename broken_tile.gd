extends Node2D

@onready var sprite = $StaticBody2D/AnimatedSprite2D
@onready var secretArea = $"../secretArea"
var life = 2
func _ready() -> void:
	secretArea.enabled = true
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "attackArea":
		life -= 1
		sprite.frame += 1
		if life < 0:
			secretArea.enabled = false
			queue_free()

		

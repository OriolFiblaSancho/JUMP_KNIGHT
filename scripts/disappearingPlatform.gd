extends StaticBody2D

@onready var anim = $AnimationPlayer

var canDisappear = true

func _on_body_area_entered(area):
	if area.name == "floorArea" and canDisappear:
		canDisappear = false
		anim.play("dissapear")
		await get_tree().create_timer(2.0).timeout
		canDisappear = true
		anim.play("appear")

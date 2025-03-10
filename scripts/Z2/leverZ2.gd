extends Area2D

func _ready() -> void:
	$Sprite2D.frame = 1

func _physics_process(delta: float) -> void:
	if Global.isLevelOn == 1:
		$Sprite2D.frame = 0


func _on_area_entered(area: Area2D) -> void:
	if area.name == "attackArea":
		$Sprite2D.frame = 0
		Global.isLevelOn = 1

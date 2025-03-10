extends Area2D
#frame 0 = encendido
#frame 1 = apagado
func _ready() -> void:
	$Sprite2D.frame = 1

func _physics_process(delta: float) -> void:
	if !Global.isLeverOn:
		$Sprite2D.frame = 1

func _on_area_entered(area: Area2D) -> void:
	if area.name == "attackArea":
		if Global.isLeverActivable:
			if !Global.isLeverOn:
				Global.isLeverOn = 1
				Global.isLeverActivable = 0
				$Sprite2D.frame = 0
			else:
				Global.isLeverOn = 0
				Global.isLeverActivable = 0
				$Sprite2D.frame = 1

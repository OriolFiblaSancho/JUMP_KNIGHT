extends Node

var playerPosition: Vector2 = Vector2.ZERO
var deathCount: int = 0
var time = 0.0


func _process(delta: float) -> void:
	time += delta
	
func timeToString() -> String:
	var msec = fmod(time,1) * 1000
	var sec = fmod(time,60)
	var min = time/60
	var format_string = "%02d : %02d : %02d"
	var actual_string = format_string % [min,sec,msec]
	return actual_string

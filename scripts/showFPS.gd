extends Control

func _process(delta: float) -> void:
	$Label.text = str(Engine.get_frames_per_second())

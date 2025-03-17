extends Node2D

var is_hoverSoundActivate = false
var last_hovered_button = null

func _ready() -> void:
	$mainMenuMusic.play()
	
func _process(delta: float) -> void:
	var current_button = null
	
	if !$mainMenuMusic.is_playing():
		$mainMenuMusic.play()
	
	if $ButtonManager/play.is_hovered():
		current_button = $ButtonManager/play
	elif $ButtonManager/options.is_hovered():
		current_button = $ButtonManager/options
	elif $ButtonManager/exit.is_hovered():
		current_button = $ButtonManager/exit
	
	# Si el botón actual con hover es diferente al último botón con hover
	if current_button != last_hovered_button:
		if current_button != null:  # Si hay un botón con hover
			hoverSound()
		
		last_hovered_button = current_button
		
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Z1/Z1LVL1.tscn")
	
func _on_options_pressed() -> void:
	pass # Replace with function body.
	
func _on_exit_pressed() -> void:
	get_tree().quit()
	
func hoverSound():
	$buttonHoverSound.play()

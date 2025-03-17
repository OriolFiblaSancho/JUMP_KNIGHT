extends Area2D

@export var nextLevel: String  # Para definir el nivel al que se viaja en el editor
@export var spawnPositionY: int
@export var spawnPositionX: int
func _on_body_entered(body: CharacterBody2D) -> void:
	if body is CharacterBody2D:
		Global.playerPosition.x = spawnPositionX  # Guardamos solo la X
		Global.playerPosition.y = spawnPositionY  # Se usa el valor exportado
		print("Guardando posición en Global:", Global.playerPosition)
		Global.deathCount = body.deathCount
		print("Guardando contador de muertes en Global: ", Global.deathCount)  # DEBUG
		get_tree().change_scene_to_file(nextLevel)
		

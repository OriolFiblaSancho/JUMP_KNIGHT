extends HBoxContainer

@onready var heartGuiClass = preload("res://scenes/heart_gui.tscn")

func setMaxHeart(max:int):
	for i in range(max):
		var heart = heartGuiClass.instantiate()
		add_child(heart)

func updateHeart(currentHealth:int):
	var hearts = get_children()
	
	for i in range(currentHealth):
		hearts[i].update(true)
	
	for i in range(currentHealth, hearts.size()):
		hearts[i].update(false)
	

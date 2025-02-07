extends Panel

@onready var sprite = $Sprite2D
var wholeHeart = preload("res://assets/demoCube3.png")
var emptyHeart = preload("res://assets/demoCube4.png")

func update(whole: bool):
	if whole: sprite.texture = wholeHeart
	else: sprite.texture = emptyHeart

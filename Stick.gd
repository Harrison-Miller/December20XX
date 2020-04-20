extends Node2D

export var fuel_amount = 0

func _ready() -> void:
	$Sprite.frame = randi()%2
	$Sprite.flip_h = randi()%2 == 0
	$Sprite.flip_v = randi()%2 == 0

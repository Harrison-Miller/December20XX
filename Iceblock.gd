extends StaticBody2D

export var has_beacon = false
var beacon_scene = preload("res://Beacon.tscn")

export var has_human = false

func _ready() -> void:
	$Sprite.frame = 0
	if has_beacon:
		$Sprite.frame = 2
		
	if has_human:
		$Sprite.frame = 4

var health = 2

func chop(player):
	if player:
		$IceBreak.play()
		
	health -= 1
	if health == 1:
		$Sprite.frame += 1
	else:
		if has_beacon:
			var beacon = beacon_scene.instance()
			get_parent().add_child(beacon)
			beacon.global_position = global_position
		
		# delete self
		get_parent().remove_child(self)
		queue_free()
	

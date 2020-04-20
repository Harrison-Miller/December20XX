extends Node2D

var health = 2

func _ready() -> void:
	$Sprite.visible = false
	$Sprite.frame = 0

func damage():
	health -= 1
	if health == 1:
		$Sprite.visible = true
	else:
		if !$AnimationPlayer.is_playing():
			$AnimationPlayer.play("Idle")

func _on_PlayerDetector_body_entered(body: Node) -> void:
	damage()
	$IceBreak.play()
	if health <= 0:
		body.ice_cube_in_water()
		body.global_position = global_position - Vector2(0, 4)
		body.get_node("FakeWater").global_position = global_position + Vector2(0, 8)

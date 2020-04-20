extends Sprite

func _ready() -> void:
	frame = 0


func _on_Area2D_body_entered(body: Node) -> void:
	$Area2D.set_deferred("monitoring", false)
	$AnimationPlayer.play("Blink")
	get_tree().call_group("icecrack", "damage")
	body.start_skit("giant_wake")
	$IceBreak.play()
	$Roar.play()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Blink":
		frame = 0

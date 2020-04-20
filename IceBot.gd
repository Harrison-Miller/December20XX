extends KinematicBody2D

var iceblock_scene = preload("res://Iceblock.tscn")
var rubble_scene = preload("res://IcebotRubble.tscn")

var awake = false
var target = null
const speed = 20
var attack_ready = true
var attacking = false

var check_lazer = false
var target_pos = Vector2.ZERO
var real_target_pos = Vector2.ZERO

var hit = false

func _ready() -> void:
	$Sprite.frame = 0
	$Lazer.visible = false
	$Footsteps.emitting = false
	
func _physics_process(delta: float) -> void:
	if attacking && check_lazer:
		if $RayCast2D.is_colliding():
			var player = $RayCast2D.get_collider()
			player.ice_cube()
			$FollowRange.monitoring = false
			target = null
			hit = true
	
	if awake && target:
		var diff = target.global_position - global_position
		if !attacking:
			if attack_ready:
				# get in attack range
				move_and_slide(diff.normalized() * speed)
			else:
				# run away
				move_and_slide(-diff.normalized() * speed)
		
		if attack_ready && diff.length() <= 64:
			$Footsteps.emitting = false
			$AnimationPlayer.play("Attack")
			attack_ready = false
			attacking = true
			
			$Lazer.visible = true
			$Lazer.points[1] = $Lazer.points[0]
			$Lazer.width = 0.5
			
			real_target_pos = target.global_position
			target_pos = transform.xform_inv(target.global_position)
			
			$LazerTween.remove_all()
			$LazerTween.interpolate_method(self, "lazer_tween", $Lazer.points[0], target_pos, 2, Tween.TRANS_EXPO, Tween.EASE_IN)
			$LazerTween.interpolate_callback(self, 2, "lazer_callback")
			$LazerTween.start()

func lazer_tween(pos):
	$Lazer.points[1] = pos
	
func lazer_callback():
	check_lazer = true
	$RayCast2D.enabled = true
	$RayCast2D.cast_to = target_pos
	$Lazer.width = 2

func _on_FollowRange_body_entered(body: Node) -> void:
	$AnimationPlayer.play("TurnOn")
	target = body

func _on_FollowRange_body_exited(body: Node) -> void:
	if !attacking:
		$Sprite.frame = 0
		$AnimationPlayer.stop()
		awake = false
		$Footsteps.emitting = false
	target = null

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "TurnOn":
		awake = true
		$AnimationPlayer.play("Walk")
		$Footsteps.emitting = true
	elif anim_name == "Attack":
		yield(get_tree().create_timer(2), "timeout")
		
		$Lazer.visible = false
		check_lazer = false
		$RayCast2D.enabled = false
		
		if !hit:
			var iceblock = iceblock_scene.instance()
			get_parent().add_child(iceblock)
			iceblock.global_position = real_target_pos
		
		$AttackCooldown.start()
		attacking = false
		if !target:
			$Sprite.frame = 0
			$AnimationPlayer.stop()
			awake = false
			$Footsteps.emitting = false
		else:
			$AnimationPlayer.play("Walk")
			$Footsteps.emitting = true

func _on_AttackCooldown_timeout() -> void:
	attack_ready = true
	
func chop(player):
	var rubble = rubble_scene.instance()
	rubble.global_position = global_position
	rubble.flip_h = randi()%2 == 0
	get_parent().add_child(rubble)
	
	get_parent().remove_child(self)
	queue_free()

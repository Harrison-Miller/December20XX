extends KinematicBody2D


const speed = 60
var fuel_in_hand = 0
export var has_axe = false

var chopping = false

var anim_prefix = ""

var step_count = 0

var beacon_count = 0

var on_ice = false
var last_dir = Vector2.ZERO

var vel = Vector2.ZERO
const accel = 0.8
const max_vel = 60
const damping = 0.99

var is_ice_cube = false
var is_cube_in_water = false

var inside = false

func _ready():
	$Snow.emitting = true
	$AnimationPlayer.play("Idle")
	$BeaconAnimation.play("Blink")
	$Beacon.visible = false
	
func chop_success():
	stop_chopping()
	$Chop.play()
	var choppables = $ChopRange.get_overlapping_areas()
	for area in choppables:
		if area.has_method("chop"):
			area.chop(self)
		
		var c = area.get_parent()
		if c.has_method("chop"):
			c.chop(self)
	
func chop_fail():
	stop_chopping()
	$ChopMiss.play()

func stop_chopping():
	chopping = false
	update_holding_fuel()
	
var bob_time = 0
	
func _process(delta):
	if is_ice_cube && is_cube_in_water:
		bob_time += delta
		$Sprite.position.y = sin(bob_time)*4 - 4
		$Sprite.rotation = cos(bob_time/1.5)/6
		return
	
func _physics_process(delta: float) -> void:
	if chopping || is_ice_cube:
		return
		
	var dir = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up"))
		

	
	if dir != Vector2.ZERO:
		last_dir = dir
		if !on_ice &&  !inside:
			$Footsteps.emitting = true
		$AnimationPlayer.play(anim_prefix + "Walk")
		if step_count == 0:
			if !$Step.playing:
				$Step.play()
		step_count += 1
		step_count %= 45
	else:
		$Footsteps.emitting = false
		$AnimationPlayer.play(anim_prefix + "Idle")
	
	if dir.x != 0:
		$Sprite.flip_h = dir.x < 0
		if $Sprite.flip_h:
			$Beacon.flip_h = true
			$Beacon.offset.x = 4
		else:
			$Beacon.flip_h = false
			$Beacon.offset.x = -4
		
	if !on_ice:
		move_and_slide(dir.normalized() * speed)
	else:
		vel += dir.normalized() * accel
		if vel.length() > max_vel:
			vel = vel.normalized() * max_vel
		move_and_slide(vel)
		vel *= damping
		
	if Input.is_action_just_released("interact") && has_axe:
		$HoldTimer.stop()

	if Input.is_action_just_pressed("interact"):
		if has_axe:
			$HoldTimer.start()
		
		var interactables = $InteractRange.get_overlapping_areas()
		for area in interactables:
			var item = area.get_parent()
			
			if item.is_in_group("bunker"):
				if area.is_in_group("leftbunker"):
					item.fuel_left += fuel_in_hand
					fuel_in_hand = 0
					update_holding_fuel()
					break
					
				if area.is_in_group("rightbunker"):
					item.fuel_right += fuel_in_hand
					fuel_in_hand = 0
					update_holding_fuel()
					break
			
			if item.is_in_group("firebot"):
				if beacon_count > 0:
					item.beacon_count += beacon_count
					beacon_count = 0
					$Beacon.visible = false
					item.update_beacon()
					if prompt_item == item:
						var prompt = get_node("/root/ButtonPrompt")
						prompt.hide()
					
				if fuel_in_hand > 0:
					item.fuel += fuel_in_hand
					fuel_in_hand = 0
					update_holding_fuel()
					if prompt_item == item:
						var prompt = get_node("/root/ButtonPrompt")
						prompt.hide()
					break
			
			if item.is_in_group("fuel"):
				$Pickup.play()
				fuel_in_hand += item.fuel_amount
				update_holding_fuel()

				# delete it
				item.get_parent().remove_child(item)
				item.queue_free()
				break
				
			if item.is_in_group("axe"):
				has_axe = true
				var prompt = get_node("/root/ButtonPrompt")
				prompt.axe_prompt()
				
				# delete it
				item.get_parent().remove_child(item)
				item.queue_free()
				break
				
			if item.is_in_group("beacon"):
				beacon_count += 1
				$Beacon.visible = true
				item.get_parent().remove_child(item)
				item.queue_free()
				break
				
func update_holding_fuel():
	anim_prefix = ""
	if fuel_in_hand > 0:
		anim_prefix = "Fuel"
		
	$AnimationPlayer.play(anim_prefix + "Idle")


func _on_HoldTimer_timeout() -> void:
	if Input.is_action_pressed("interact"):
		chopping = true
		$AnimationPlayer.play("ChopIdle")
		$ChopUI.start_chopping()
		var prompt = get_node("/root/ButtonPrompt")
		prompt.finish_axe_tutorial()


func _on_IceDetector_area_entered(area: Area2D) -> void:
	on_ice = true
	vel = last_dir * max_vel/2.5
	$Footsteps.emitting = false


func _on_IceDetector_area_exited(area: Area2D) -> void:
	on_ice = false
	
func ice_cube_in_water():
	$Sprite.frame = 16
	is_ice_cube = true
	is_cube_in_water = true
	$Footsteps.emitting = false
	$AnimationPlayer.stop()
	chopping = false
	$ChopUI.visible = false
	$FakeWater.visible = true
	$Beacon.visible = false
	
	var gameover = get_node("/root/GameOver")
	gameover.start_game_over()
	
func ice_cube():
	$Sprite.frame = 16
	is_ice_cube = true
	$Footsteps.emitting = false
	$AnimationPlayer.stop()
	chopping = false
	$ChopUI.visible = false
	$Beacon.visible = false
	
	var gameover = get_node("/root/GameOver")
	gameover.start_game_over()

var prompt_item = null

func _on_InteractRange_area_entered(area: Area2D) -> void:
	var prompt = get_node("/root/ButtonPrompt")
	
	var item = area.get_parent()
	if item.is_in_group("fuel"):
		prompt.interact_prompt("pickup wood")
		prompt_item = item
		
	if item.is_in_group("beacon"):
		prompt.interact_prompt("pickup beacon")
		prompt_item = item
		
	if item.is_in_group("axe"):
		prompt.interact_prompt("pickup axe")
		prompt_item = item
		
	if item.is_in_group("firebot"):
		if beacon_count > 0:
			prompt.interact_prompt("give beacon")
			prompt_item = item
		elif fuel_in_hand > 0:
			prompt.interact_prompt("give wood")
			prompt_item = item
			
	if item.is_in_group("bunker"):
		if fuel_in_hand > 0:
			prompt.interact_prompt("give wood")
			prompt_item = item


func _on_InteractRange_area_exited(area: Area2D) -> void:
	var item = area.get_parent()
	if item == prompt_item:
		var prompt = get_node("/root/ButtonPrompt")
		prompt.hide()
		
func end_credits():
	is_ice_cube = true
	$AnimationPlayer.play("Idle")
	$Footsteps.emitting = false
	$ChopUI.visible = false
	$Beacon.visible = false
	yield(get_tree().create_timer(1), "timeout")
	get_parent().remove_child(self)
	queue_free()

onready var speech = $SpeechAnchor/SpeechBubble

func hide_skits():
	speech.hide_text()

func start_skit(skit_name):
	if skit_name == "hunk_of_junk":
		speech.set_text("Let's go you hunk of junk")
	if skit_name == "trail_head":
		speech.set_text("Harding Lake State Park")
	if skit_name == "lake_sign":
		speech.set_text("Harding Lake", 1)
		yield(get_tree().create_timer(1.5), "timeout")
		speech.set_text("Sure does ook beautiful frozen over")
	if skit_name == "ice_skating":
		speech.set_text("I always did like ice skating...", 2)
		yield(get_tree().create_timer(2.5), "timeout")
		speech.set_text("I should be careful not to crack the ice")
	if skit_name == "buried_in_lake":
		speech.set_text("What is that doing frozen in the lake...")
	if skit_name == "giant_wake":
		speech.set_text("[shake rate=5 level=5]oh god, oh god, I gotta run[/shake]")
	if skit_name == "skeleton":
		speech.set_text("Poor guy...", 2)
		yield(get_tree().create_timer(2.5), "timeout")
		speech.set_text("Why is his arm torn off...")
	if skit_name == "cabin_inside":
		speech.set_text("This place was wrecked")
	if skit_name == "first_encounter":
		speech.set_text("That robot doesn't look so friendly")
		yield(get_tree().create_timer(2), "timeout")
		var firebot = get_tree().get_nodes_in_group("firebot")[0]
		firebot.start_skit("first_encounter_response")
	if skit_name == "warzone":
		speech.set_text("This is literally a warzone", 2)
		yield(get_tree().create_timer(2.5), "timeout")
		speech.set_text("The world really went to hell after...")
	if skit_name == "i_know":
		speech.set_text("Jeez, I know already!")

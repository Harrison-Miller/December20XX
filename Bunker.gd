extends StaticBody2D

var fuel_left = 0
var fuel_right = 10

const fire_state_small = 60
const fire_state_medium = 120
const fire_state_large = 180

func _ready() -> void:
	$Door.frame = 0
	$Puzzle.frame = 0
	$FireLeft.visible = false
	$FireRight.visible = false
	$SparksLeft.visible = false
	$SparksRight.visible = false

func _on_FireBotDetector_body_entered(body: Node) -> void:
	var firebot = body.get_parent()
	if firebot.is_in_group("firebot"):
		$Puzzle.frame = 1
		$FireLeft.visible = true
		$FireRight.visible = true
		$SparksLeft.visible = true
		$SparksRight.visible = true
		
		fuel_left = firebot.fuel
		update_fuel()
		
		firebot.get_parent().remove_child(firebot)
		firebot.queue_free()
		
		$FuelTimer.start()

func _on_FuelTimer_timeout() -> void:
	fuel_left -= 1
	fuel_right -= 1
	update_fuel()
	
func update_fuel():
	# flames can't go out in the bunker
	if fuel_left <= 0:
		fuel_left = 1
		
	if fuel_right <= 0:
		fuel_right = 1
		
	# update animations
	if fuel_left < fire_state_small:
		$FireLeftAnimation.play("small")
	elif fuel_left < fire_state_medium:
		$FireLeftAnimation.play("medium")
	elif fuel_left < fire_state_large:
		$FireLeftAnimation.play("large")
	else:
		$FireLeftAnimation.play("xlarge")

	if fuel_right < fire_state_small:
		$FireRightAnimation.play("small")
	elif fuel_right < fire_state_medium:
		$FireRightAnimation.play("medium")
	elif fuel_right < fire_state_large:
		$FireRightAnimation.play("large")
	else:
		$FireRightAnimation.play("xlarge")

	# update puzzle
	if fuel_left >= fire_state_medium && fuel_right >= fire_state_medium:
		$Puzzle.frame = 4
		$DoorAnimation.play("Open")
		$FuelTimer.stop()
	elif fuel_left >= fire_state_medium:
		$Puzzle.frame = 2
	elif fuel_right >= fire_state_medium:
		$Puzzle.frame = 3
	else:
		$Puzzle.frame = 1


func _on_PlayerTrigger_body_entered(body: Node) -> void:
	body.end_credits()
	
	var endcredits = get_node("/root/EndCredits")
	endcredits.start_end_credits()

func _on_DoorAnimation_animation_finished(anim_name: String) -> void:
	if anim_name == "Open":
		$PlayerTrigger.monitoring = true

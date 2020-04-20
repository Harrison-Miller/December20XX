extends Node2D

export var fuel = 59
const fire_state_small = 60
const fire_state_medium = 120
const fire_state_large = 180
const speed = 20
var waiting_for_beacon = false

var low_power_skit_played = false
var first_power_on_skit_played = false
var first_beacon_acquired_skit_played = false

export var path_path = ""
var path = null

var beacon_count = 0

export var robot_on = false

func _ready():
	$FuelTimer.start()
	update_fire()
	$Sprite.frame = 0
	$Footsteps.emitting = false
	
	if fuel >= fire_state_medium:
		robot_on = true
		$AnimationPlayer.play("Walk")
		$Footsteps.emitting = true
	
	if path_path != "":
		path = get_node(path_path)
	
func _on_FuelTimer_timeout() -> void:
	fuel -= 1
	if fuel <= 50:
		fuel = 50
	update_fire()
	
func add_fuel(amount):
	fuel += amount
	update_fire()

func update_fire():
	if fuel < fire_state_small:
		$FireAnimation.play("small")
	elif fuel < fire_state_medium:
		$FireAnimation.play("medium")
	elif fuel < fire_state_large:
		$FireAnimation.play("large")
	else:
		$FireAnimation.play("xlarge")
		
	if !waiting_for_beacon:
		if !robot_on && fuel >= fire_state_medium && !$AnimationPlayer.is_playing():
			$BigFire.play()
			$BeepBoop.play()
			$AnimationPlayer.play("TurnOn")
			if !first_power_on_skit_played:
				first_power_on_skit_played = true
				start_skit("startup_sequence")
		elif robot_on && fuel < fire_state_medium:
			$BigFire.stop()
			if !low_power_skit_played:
				start_skit("low_power")
				low_power_skit_played = true
			$Sprite.frame = 0
			$AnimationPlayer.stop()
			robot_on = false
			$Footsteps.emitting = false
		
func _physics_process(delta: float) -> void:
	if !waiting_for_beacon && robot_on && path:
		path.offset += speed*delta
		
func get_offset():
	if path:
		return path.offset
		
func set_offset(offset):
	if path:
		path.offset = offset

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "TurnOn":
		robot_on = true
		$AnimationPlayer.play("Walk")
		$Footsteps.emitting = true

func _on_BeaconDetector_area_entered(area: Area2D) -> void:
	if beacon_count > 0:
		beacon_count -= 1
		return

	waiting_for_beacon = true
	$AnimationPlayer.play("BeaconIdle")
	$Footsteps.emitting = false
	
	var gameover = get_node("/root/GameOver")
	gameover.save_checkpoint()
	
func update_beacon():
	if waiting_for_beacon && beacon_count > 0:
		waiting_for_beacon = false
		beacon_count -= 1
		if robot_on:
			$AnimationPlayer.play("Walk")
			$Footsteps.emitting = true
		else:
			$AnimationPlayer.stop()
			robot_on = false
			$Footsteps.emitting = false

onready var speech = $SpeechAnchor/SpeechBubble
		
		
func hide_skits():
	speech.hide_text()
	
func start_skit(skit_name):
	if skit_name == "startup_sequence":
		speech.set_text("Startup sequence initiated...", 1)
		yield(get_tree().create_timer(1.5), "timeout")
		speech.set_text("I am [color=red]hearth[/color] bot your campfire campanion")
		yield(get_tree().create_timer(1.5), "timeout")
		var player = get_tree().get_nodes_in_group("player")[0]
		player.start_skit("i_know")
	if skit_name == "low_power":
		speech.set_text("Low power mode, fuel needed")
	if skit_name == "beacon_1":
		speech.set_text("Beacon detected nearby...", 2)
		yield(get_tree().create_timer(2.5), "timeout")
		speech.set_text("retrieve it to continue")
	if skit_name == "lake_beacon":
		speech.set_text("Anomaly detected in the lake")
		yield(get_tree().create_timer(3), "timeout")
		var player = get_tree().get_nodes_in_group("player")[0]
		player.start_skit("ice_skating")
	if skit_name == "first_encounter_response":
		speech.set_text("Ice drone threat detected", 2)
	if skit_name == "cabin_beacon":
		speech.set_text("Beacon signal nearby")
	if skit_name == "hostiles":
		speech.set_text("Multiple hostiles nearby")
	if skit_name == "bunker":
		speech.set_text("Maximum power required to open bunker door")

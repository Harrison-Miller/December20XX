extends CanvasLayer

var firebot_offset = 0
var firebot_fuel = 0
var firebot_beacon_count = 0
var player_position = Vector2.ZERO
var player_fuel_count = 0
var player_beacon_count = 0
var player_has_axe = false
var beacons_left = []
var iceblocks_left = []
var icebots_left = []
var cabin_door_broken = false
var skits_left = []

var world_scene = preload("res://World.tscn")

var game_over = false

# TODO: save beacons that have been picked up
# save if the cabin door was destroyed
# save ice blocks that were destroyed

func _ready():
	reset()

func reset():
	game_over = false

	$GUI.visible = false
	$GUI/VBoxContainer.visible = false
	$RichTextLabel.visible = false
	$ColorRect.visible = false

func start_game_over():
	$GUI.visible = true
	$ColorRect.visible = true
	$ColorRect.color = Color(0, 0, 0, 0)
	
	$Tween.remove_all()
	$Tween.interpolate_property($ColorRect, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 0.5), 1)
	$Tween.interpolate_callback(self, 1, "show_buttons")
	$Tween.start()

func show_buttons():
	$GUI/VBoxContainer.visible = true
	$RichTextLabel.visible = true

func save_checkpoint():
	var firebot = get_tree().get_nodes_in_group("firebot")[0]
	firebot_offset = firebot.get_offset()
	firebot_fuel = firebot.fuel
	firebot_beacon_count = firebot.beacon_count
	
	var player = get_tree().get_nodes_in_group("player")[0]
	player_position = player.global_position
	player_fuel_count = player.fuel_in_hand
	player_beacon_count = player.beacon_count
	player_has_axe = player.has_axe
	
	var cabindoor = get_tree().get_nodes_in_group("cabindoor")[0]
	cabin_door_broken = cabindoor.health <= 0
	
	beacons_left.clear()
	var beacons = get_tree().get_nodes_in_group("beacon")
	for b in beacons:
		beacons_left.push_back(b.get_path())
		
	iceblocks_left.clear()
	var iceblocks = get_tree().get_nodes_in_group("iceblock")
	for i in iceblocks:
		iceblocks_left.push_back(i.get_path())
		
	icebots_left.clear()
	var icebots = get_tree().get_nodes_in_group("icebot")
	for i in icebots:
		icebots_left.push_back(i.get_path())
		
	skits_left.clear()
	var skits = get_tree().get_nodes_in_group("skit")
	for i in skits:
		skits_left.push_back(i.get_path())
	
func apply_checkpoint():
	restart_game()
	
	yield(get_tree().create_timer(0.01), "timeout")

	# get rid of tutorial
	var prompt = get_node("/root/ButtonPrompt")
	prompt.to_move = false
	prompt.hide()
	
	var firebot = get_tree().get_nodes_in_group("firebot")[0]
	firebot.set_offset(firebot_offset)
	firebot.fuel = firebot_fuel
	firebot.beacon_count = firebot_beacon_count
	
	var player = get_tree().get_nodes_in_group("player")[0]
	var cam = player.get_node("Camera2D")
	cam.current = false
	player.global_position = player_position
	cam.current = true
	cam.reset_smoothing()
	
	player.fuel_in_hand = player_fuel_count
	player.beacon_count = player_beacon_count
	if player.beacon_count > 0:
		player.get_node("Beacon").visible = true
	player.has_axe = player_has_axe
	
	if player_has_axe:
		var axe = get_tree().get_nodes_in_group("axe")[0]
		axe.get_parent().remove_child(axe)
		axe.queue_free()
		
	player.update_holding_fuel()
	
	if cabin_door_broken:
		var cabindoor = get_tree().get_nodes_in_group("cabindoor")[0]
		cabindoor.health = 0
		cabindoor.chop(null)

	
	var beacons = get_tree().get_nodes_in_group("beacon")
	for b in beacons:
		if !beacons_left.has(b.get_path()):
			b.get_parent().remove_child(b)
			b.queue_free()
			
	var iceblocks = get_tree().get_nodes_in_group("iceblock")
	for i in iceblocks:
		if !iceblocks_left.has(i.get_path()):
			i.get_parent().remove_child(i)
			i.queue_free()
			
	var icebots = get_tree().get_nodes_in_group("icebot")
	for i in icebots:
		if !icebots_left.has(i.get_path()):
			i.get_parent().remove_child(i)
			i.queue_free()
			
	var skits = get_tree().get_nodes_in_group("skit")
	for i in skits:
		if !skits_left.has(i.get_path()):
			i.get_parent().remove_child(i)
			i.queue_free()
			
	player.hide_skits()
	firebot.hide_skits()
	
func restart_game():
	reset()
	get_tree().reload_current_scene()


func _on_LastCheckpoint_button_down() -> void:
	apply_checkpoint()


func _on_Restart_button_down() -> void:
	restart_game()

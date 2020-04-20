extends StaticBody2D

var stick_scene = preload("res://Stick.tscn")
var log_scene = preload("res://Log.tscn")

const fall_time = 1

func spawn_sticks(count, pos, drop_range):
	for i in range(count):
		var stick = stick_scene.instance()
		get_parent().call_deferred("add_child", stick)
		var offset = Vector2(rand_range(-drop_range, drop_range), rand_range(-drop_range, drop_range))
		stick.global_position = pos + offset
		
func spawn_logs(count, pos, drop_range):
	for i in range(count):
		var stick = log_scene.instance()
		get_parent().call_deferred("add_child", stick)
		var offset = Vector2(rand_range(-drop_range, drop_range), rand_range(-drop_range, drop_range))
		stick.global_position = pos + offset
		
func _ready() -> void:
	$Pivot/Sprite.frame = randi()%4
	$Pivot/Sprite.flip_h = randi()%2 == 0
	$Stump.frame = $Pivot/Sprite.frame + 12
	$Stump.flip_h = $Pivot/Sprite.flip_h
	
	var stick_count = randi()%4 - 1
	spawn_sticks(stick_count, global_position, 24)

var health = 2

func chop(player):
	health -= 1
	if health == 1:
		$Pivot/Sprite.frame += 4
	elif health <= 0:
		$Fall.play()
		$Pivot/Sprite.frame += 4
		$Stump.visible = true
		$Area2D.monitorable = false
		if player.global_position.x > global_position.x:
			$Tween.interpolate_property($Pivot, "rotation_degrees", 0, -90, fall_time, Tween.TRANS_EXPO, Tween.EASE_IN)
		
		else:
			$Tween.interpolate_property($Pivot, "rotation_degrees", 0, 90, fall_time, Tween.TRANS_EXPO, Tween.EASE_IN)
		$Tween.interpolate_callback(self, fall_time, "fall_finished", player.global_position.x > global_position.x)
		$Tween.start()
	
func fall_finished(fall_left):
	if fall_left:
		spawn_sticks(randi()%2 + 1, global_position - Vector2(16, 0), 12)
		spawn_logs(2, global_position - Vector2(16, 0), 12)
	else:
		spawn_sticks(randi()%2 + 1, global_position + Vector2(16, 0), 12)
		spawn_logs(2, global_position + Vector2(16, 0), 12)
		
	$Pivot.visible = false

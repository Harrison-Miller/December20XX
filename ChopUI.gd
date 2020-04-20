extends Node2D

var game_size = 24
var target_width = 3
var target_radius = 0
var mark_radius = 0
var mark_in = false         
var mark_speed = 16
var pause = false

var rng = RandomNumberGenerator.new()

func _ready():
	visible = false
	rng.randomize()

func start_chopping(width = 3, speed = 16):
	visible = true
	target_width = width
	target_radius = rng.randf_range(0, game_size)
	target_radius = max(target_radius, 3.5)
	print(target_radius)
	mark_radius = 0
	mark_in = true
	mark_speed = speed
	pause = false
	update()

func _process(delta: float) -> void:
	if visible && !pause:
		if mark_in:
			mark_radius -= mark_speed*delta
			if mark_radius <= 0:
				mark_radius = 0
				mark_in = false
		else:
			mark_radius += mark_speed*delta
			if mark_radius >= game_size:
				mark_radius = game_size
				mark_in = true
			
		update()
		
		if Input.is_action_just_released("interact"):
			get_parent().get_node("AnimationPlayer").play("Chop")
			pause = true
	
func _draw():
	draw_circle(Vector2.ZERO, game_size, Color(0, 0, 0, 0.2))
	
	draw_arc(Vector2.ZERO, target_radius, 0, 2*PI, 16, Color(0, 1.0, 0, 0.5), target_width)
	
	draw_arc(Vector2.ZERO, mark_radius, 0, 2*PI, 16, Color(1.0, 1.0, 0), 1.2)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Chop":
		visible = false
		var p = get_parent()
		
		if target_radius + 1.5 >= mark_radius && target_radius - 1.5 <= mark_radius:
			p.chop_success()
		else:
			p.chop_fail()

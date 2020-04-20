extends Area2D

export var teleport_node_path = ""
export var teleport_pos = Vector2.ZERO
var allow_teleport = false

func _ready() -> void:
	$Sprite.frame = 0
	var n = get_node(teleport_node_path)
	if n:
		teleport_pos = n.global_position

var health = 3

func chop(player):
	health -= 1
	if health == 2:
		$Sprite.frame = 1
	elif health == 1:
		$Sprite.frame = 2
	else:
		$Sprite.visible = false
		monitorable = false
		allow_teleport = true
		$StaticBody2D/CollisionShape2D.disabled = true

func _on_PlayerTrigger_body_entered(body: Node) -> void:
	if allow_teleport:
		body.inside = true
		body.get_node("Footsteps").emitting = false
		body.get_node("Snow").visible = false

		var cam = body.get_node("Camera2D")
		cam.current = false
		body.global_position = teleport_pos
		cam.current = true
		cam.reset_smoothing()

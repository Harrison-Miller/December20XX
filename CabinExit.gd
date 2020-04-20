extends Area2D


export var node_path = ""
var pos = Vector2.ZERO

func _ready():
	var n = get_node(node_path)
	if n:
		pos = n.global_position

func _on_CabinExit_body_entered(body: Node) -> void:
	var cam =body.get_node("Camera2D")
	body.inside = false
	body.get_node("Snow").visible = true
	
	cam.current = false
	body.global_position = pos 
	cam.current = true
	cam.reset_smoothing()

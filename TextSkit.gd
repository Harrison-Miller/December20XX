extends Area2D

export var skit_name = ""
export var delete_after_player = true
export var delete_after_firebot = false

func _on_TextSkit_body_entered(body: Node) -> void:
	if body.has_method("start_skit"):
		body.start_skit(skit_name)
	elif body.get_parent().has_method("start_skit"):
		body.get_parent().start_skit(skit_name)

	if delete_after_player && body.is_in_group("player"):
		get_parent().remove_child(self)
		queue_free()
		
	if delete_after_firebot && body.is_in_group("firebot"):
		get_parent().remove_child(self)
		queue_free()
		

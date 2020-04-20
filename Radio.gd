extends Node2D


func _ready() -> void:
	$Timer.start()
	
func _on_Timer_timeout() -> void:
	$SpeechBubble.set_text("Emergency Broadcast Services Alert")
	yield(get_tree().create_timer(3.5), "timeout")
	$SpeechBubble.set_text("Seek shelter immediately")
	yield(get_tree().create_timer(3.5), "timeout")
	$SpeechBubble.set_text("This is not a test")

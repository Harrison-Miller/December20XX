extends CanvasLayer

func _ready() -> void:
	$ColorRect.visible = false
	$RichTextLabel.visible = false
	
func start_end_credits():
	$ColorRect.visible = true
	$ColorRect.color = Color(0, 0, 0, 0)
	
	$Tween.remove_all()
	$Tween.interpolate_property($ColorRect, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 1)
	$Tween.interpolate_callback(self, 1, "show_credits")
	$Tween.start()

func show_credits():
	$RichTextLabel.visible = true

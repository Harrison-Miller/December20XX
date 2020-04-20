extends Node2D

const character_time = 0.02

var regex = RegEx.new()

func _ready() -> void:
	visible = false
	regex.compile("\\[(.+?)\\]")
	
func hide_text():
	$Timer.stop()
	visible = false
	
func set_text(text, timeout = 3):
	$Timer.stop()
	$Timer.wait_time = timeout
	visible = true
	$RichTextLabel.bbcode_text = text
	$RichTextLabel.margin_top = 2
	$RichTextLabel.margin_left =  2
	$RichTextLabel.margin_bottom = 10
	$ColorRect.margin_bottom = 10
	
	var real_text = regex.sub(text, "", true)
	var text_size = $RichTextLabel.get_font("normal_font").get_string_size(real_text)
	
	var t = real_text.length()*character_time
	$RichTextLabel.margin_right = text_size.x
	$ColorRect.margin_right = text_size.x - 4
	
	position.x = -text_size.x/2
	
	$Tween.remove_all()
	$Tween.interpolate_property($RichTextLabel, "percent_visible", 0, 1, t)
	$Tween.interpolate_callback(self, t, "start_timer")
	$Tween.start()
	
func start_timer():
	$Timer.start()

func _on_Timer_timeout() -> void:
	visible = false

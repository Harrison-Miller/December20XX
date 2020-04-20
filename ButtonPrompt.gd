extends CanvasLayer

var to_move = false
var axe_tutorial = false

func _ready() -> void:
	hide()
	to_move_prompt()

func hide():
	if to_move || axe_tutorial:
		return
		
	$RichTextLabel.visible = false
	$Control.visible = false

func _process(delta: float) -> void:
	if to_move:
		if Input.is_action_pressed("left") || Input.is_action_pressed("right") || Input.is_action_pressed("up") || Input.is_action_pressed("down"):
			to_move = false
			hide()
			
func finish_axe_tutorial():
	if axe_tutorial:
		axe_tutorial = false
		hide()
			
func axe_prompt():
	interact_prompt("hold to chop")
	axe_tutorial = true

func to_move_prompt():
	$RichTextLabel.visible = true
	$RichTextLabel.text = "\n to move"
	$Control.visible = true
	$Control/ControllerIcon.frame = 0
	$Control/KeyboardIcon.frame = 0
	to_move = true
	
func interact_prompt(text):
	if to_move || axe_tutorial:
		return
	$RichTextLabel.visible = true
	$RichTextLabel.text = "\n " + text
	$Control.visible = true
	$Control/ControllerIcon.frame = 1
	$Control/KeyboardIcon.frame = 1
	

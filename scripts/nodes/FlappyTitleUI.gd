class_name FlappyTitleUI

extends Node

var button: Button

func _ready():
	button = get_node('Panel/Button')
	button.connect('pressed', func (): Input.action_press('ui_select'))
	# animate()
	pass


func animate():
	var t = create_tween()
	t.set_ease(Tween.EASE_IN_OUT)
	t.set_trans(Tween.TRANS_ELASTIC) # トランジションの種類をELASTICに指定
	t.tween_property(self, "scale", Vector2.ZERO, 0)
	t.tween_property(self, "scale", Vector2.ONE * 1, 1.0)
	t.tween_interval(2.0)
	t.play()
	pass
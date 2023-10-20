class_name FlappyGameUI

extends Node

var score: RichTextLabel
var count_down: RichTextLabel
var button: Button

func initialize():
	score = get_node('Score')
	count_down = get_node('CountDown')
	button = get_node('Button')
	button.connect('pressed', func (): Input.action_press('ui_select'))
	pass

func on_count_down(count: float):
	count_down.text = '[center]' + str(floor(count))
	pass

func on_run_start():
	count_down.text = ''
	pass

func on_update_score(s: int, mag: float):
	score.text = '[center]Score:' + str(s).pad_zeros(7)

	if s == 0:
		return

	if mag > 0.5:
		count_down.text = '[center]cool'
	elif mag > 0.3:
		count_down.text = '[center]good'
	elif mag > 0.1:
		count_down.text = '[center]ok'
	else:
		count_down.text = '[center]bad'
	pass
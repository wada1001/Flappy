class_name CustomTimer

var duration: float = 0
var passed: float = 0

func _init(d = 0):
	set_duration(d)
	pass

func set_duration(d: float):
	duration = d
	passed = 0
	pass

func reset():
	passed = 0
	pass

func get_remain() -> float:
	return duration - passed

func tick(delta: float):
	passed += delta
	pass

func finished() -> bool:
	return duration < passed
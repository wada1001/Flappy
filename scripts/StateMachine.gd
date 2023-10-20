class_name StateMachine

var current_state: String
var next_state: String

enum Phase {Idle, Enter, Update, Exit}
var current_phase: Phase = Phase.Idle

var callable_state_functions: Dictionary = {}

func _init():
	pass

func register(state: String, phase: Phase, function: Callable):
	if !callable_state_functions.has(state):
		callable_state_functions[state] = { Phase.Enter: [], Phase.Update: [], Phase.Exit: []}
	
	callable_state_functions[state][phase].append(function)
	pass

func start(state: String):
	if !callable_state_functions.has(state):
		print(state + 'not found')
		return
	next_state = state
	current_phase = Phase.Enter
	pass

func request(state: String):
	if !callable_state_functions.has(state):
		print(state + 'not found')
		return
	next_state = state
	# TODO いらない気がする
	if current_phase == Phase.Idle:
		current_phase = Phase.Enter
	pass

func stop():
	next_state = ''
	current_phase = Phase.Exit
	pass

func update():
	match current_phase:
		Phase.Idle:
			return
		Phase.Enter:
			if next_state == '':
				current_phase = Phase.Idle
				return
			current_state = next_state
			next_state = ''
			for f in callable_state_functions[current_state][Phase.Enter]:
				f.call()
			current_phase = Phase.Update
			return
		Phase.Update:
			for f in callable_state_functions[current_state][Phase.Update]:
				f.call()
			if next_state != '':
				current_phase = Phase.Exit
			return
		Phase.Exit:
			for f in callable_state_functions[current_state][Phase.Exit]:
				f.call()
			current_phase = Phase.Enter
			return
	pass


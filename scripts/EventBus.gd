class_name EventBus

var callable_events_functions: Dictionary = {}

func register(event_name: String, function: Callable):
	if !callable_events_functions.has(event_name):
		callable_events_functions[event_name] = []
	
	callable_events_functions[event_name].append(function)
	pass

func fire(event_name: String, args: Array):
	if !callable_events_functions.has(event_name):
		print(event_name + 'not found')
		return
	
	var callables: Array = callable_events_functions[event_name]

	for callable in callables:
		callable.callv(args)
	pass

func clear():
	callable_events_functions = {}
	pass

class_name Flappy

extends Node2D

var game_sm = StateMachine.new()
var ui_sm = StateMachine.new()

var title_ui_node = preload("res://scenes/flappy_title.tscn")
var game_ui_node = preload("res://scenes/flappy_game.tscn")
var result_ui_node = preload("res://scenes/flappy_result.tscn")
var death_particle = preload("res://scenes/explosion.tscn")

var actor = preload("res://scenes/flappy_actor.tscn")
var game_stats = {
	'score' = 0,
}

func _ready():
	var title_ui: FlappyTitleUI = title_ui_node.instantiate()
	var game_ui: FlappyGameUI = game_ui_node.instantiate()
	var result_ui: FlappyResultUI = result_ui_node.instantiate()
	game_ui.initialize()
	result_ui.initialize()

	# TODO freeが必要
	# そもそもするか
	# var particle: CPUParticles2D = death_particle.instantiate()
	# particle.position = Vector2(300, 500)
	# self.add_child(particle)


	var bus = EventBus.new()
	bus.register('on_count_down', game_ui.on_count_down)
	bus.register('on_run_start', game_ui.on_run_start)
	bus.register('on_update_score', game_ui.on_update_score)

	ui_sm.register('title', StateMachine.Phase.Enter, enter.bind(self, title_ui))
	ui_sm.register('title', StateMachine.Phase.Update, check_input.bind(ui_sm, 'game'))
	ui_sm.register('title', StateMachine.Phase.Exit, exit.bind(self, title_ui))

	ui_sm.register('game', StateMachine.Phase.Enter, enter.bind(self, game_ui))
	ui_sm.register('game', StateMachine.Phase.Enter, game_sm.request.bind('pre_run'))
	ui_sm.register('game', StateMachine.Phase.Exit, exit.bind(self, game_ui))
	ui_sm.register('game', StateMachine.Phase.Exit, game_sm.stop)

	ui_sm.register('result', StateMachine.Phase.Enter, enter_result.bind(self, result_ui, game_stats))
	ui_sm.register('result', StateMachine.Phase.Update, check_input.bind(ui_sm, 'title'))
	ui_sm.register('result', StateMachine.Phase.Exit, exit.bind(self, result_ui))

	var player: FlappyActor = actor.instantiate()
	player.name = 'PLAYER'
	player.initialize()
	player.set_meta('velocity_y', 0)
	var walls: Array[FlappyActor] = []
	for i in range(10):
		var a = actor.instantiate()
		a.initialize()
		walls.append(a)

	# pre
	var pre_run_timer = CustomTimer.new(3)
	game_sm.register('pre_run', StateMachine.Phase.Enter, create_player.bind(self, player, pre_run_timer, bus, game_stats))
	game_sm.register('pre_run', StateMachine.Phase.Enter, reset_walls.bind(self, walls))
	game_sm.register('pre_run', StateMachine.Phase.Update, count_down.bind(self, pre_run_timer, game_sm, bus))

	game_sm.register('run', StateMachine.Phase.Update, spawn_wall.bind(self, walls, CustomTimer.new(), RandomNumberGenerator.new()))
	game_sm.register('run', StateMachine.Phase.Update, update_player.bind(self, player))
	game_sm.register('run', StateMachine.Phase.Update, update_walls.bind(self, player, walls, bus, game_stats))
	game_sm.register('run', StateMachine.Phase.Update, check_player.bind(player, game_sm))

	# pri
	game_sm.register('pri_run', StateMachine.Phase.Enter, set_pri_run.bind(player))
	game_sm.register('pri_run', StateMachine.Phase.Update, update_pri_run.bind(self, player, game_sm))
	game_sm.register('pri_run', StateMachine.Phase.Exit, ui_sm.request.bind('result'))
	
	ui_sm.start('title')
	pass

func _process(_delta: float):
	ui_sm.update()
	pass

func _physics_process(_delta: float):
	game_sm.update()
	pass
	
# ui
func enter(node: Node, ui: Node):
	node.add_child(ui)
	pass

func enter_result(node: Node, ui: FlappyResultUI, stats: Dictionary):
	ui.score.text = '[center]Score:' + str(int(stats['score'])).pad_zeros(7)
	node.add_child(ui)
	pass

func check_input(sm: StateMachine, to: String):
	if Input.is_action_just_pressed('ui_select'):
		sm.request(to)
	pass

func exit(node: Node, ui: Node):
	node.remove_child(ui)
	pass

# pre_run
func create_player(node: Node, player: FlappyActor, ctimer: CustomTimer, bus: EventBus, stats: Dictionary):
	ctimer.reset()
	stats['score'] = 0
	bus.fire('on_update_score', [stats['score'], 0])
	player.position = Vector2(200, 200)
	player.velocity = Vector2.ZERO
	player.rotation = 0
	if !player.is_inside_tree():
		node.add_child(player)
	pass

func reset_walls(node: Node, walls: Array[FlappyActor]):
	for wall in walls:
		if wall.is_inside_tree():
			node.remove_child(wall)
	pass

func count_down(node: Node, ctimer: CustomTimer, sm: StateMachine, bus: EventBus):
	ctimer.tick(node.get_physics_process_delta_time())
	bus.fire('on_count_down', [ctimer.get_remain()])
	if !ctimer.finished():
		return

	sm.request('run')
	bus.fire('on_run_start', [])
	pass

# pri_run
func set_pri_run(player: FlappyActor):
	player.velocity = Vector2(0, 50)
	pass

func update_pri_run(node: Node, player: FlappyActor, sm: StateMachine):
	player.velocity += Vector2.DOWN * 10
	player.rotation += 10 * node.get_physics_process_delta_time()
	player.move(node.get_physics_process_delta_time())
	if player.position.y < 1600:
		return

	# TODO stop
	sm.stop()
	pass

func death_player(node: Node, player: FlappyActor, ctimer: CustomTimer):
	ctimer.reset()
	player.position = Vector2(200, 200)
	player.velocity = Vector2.ZERO
	node.add_child(player)
	pass


func remove_player(node: Node, player: FlappyActor):
	node.remove_child(player)
	pass

func update_player(node: Node, player: FlappyActor):
	player.velocity += Vector2.DOWN * 10
	if Input.is_key_pressed(KEY_SPACE):
		player.velocity += Vector2.UP * 50
		pass

	player.move(node.get_physics_process_delta_time())
	pass

func check_player(player: FlappyActor, sm: StateMachine):
	if player.position.y < 0 || player.position.y > 1600:
		sm.request('pri_run')
		return

	var areas = player.get_overlapping_areas()
	if areas.is_empty():
		return
	sm.request('pri_run')
	pass

func spawn_wall(node: Node, walls: Array[FlappyActor], ctimer: CustomTimer, rng: RandomNumberGenerator):
	ctimer.tick(node.get_physics_process_delta_time())
	if !ctimer.finished():
		return

	ctimer.set_duration(rng.randf_range(1.5, 2.5))
	var wall = walls.filter(func (w: Area2D): return !w.is_inside_tree()).front()

	if wall == null:
		return
	
	wall.position = Vector2(799, rng.randf_range(100, 1500))
	wall.set_height(rng.randf_range(100, 500))
	node.add_child(wall)
	pass

func update_walls(node: Node, player:FlappyActor ,walls: Array[FlappyActor], bus: EventBus, stats: Dictionary):
	for wall in walls:
		if !wall.is_inside_tree():
			continue
		
		if wall.position.x < 0:
			node.remove_child(wall)
			continue
		
		var before_x = wall.position.x	
		wall.move_local_x(-300 * node.get_physics_process_delta_time())
		
		if before_x < player.position.x:
			continue
		
		if wall.position.x <= player.position.x:
			# 動かしてplayerを通り過ぎたら
			var distance = abs(wall.position.y - player.position.y)
			var m: float = (player.sprite.size.x + wall.sprite.size.x) / 2
			var mag: float = m / distance
			stats['score'] += 800 * mag
			bus.fire('on_update_score', [int(stats['score']), mag])
			continue
	pass

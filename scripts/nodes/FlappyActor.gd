class_name FlappyActor

extends Area2D

var velocity: Vector2 = Vector2.ZERO
var sprite: ColorRect
var collider: CollisionShape2D
var shape: RectangleShape2D

func initialize():
	sprite = get_node('ColorRect')
	collider = get_node('CollisionShape2D')
	# 同じSceneからのInstanceはShapeを共有してた
	var s = RectangleShape2D.new()
	s.size = sprite.size
	collider.shape = s
	pass

func set_height(height: float):
	sprite.size = Vector2(80, height)
	sprite.position = -1 * (sprite.size / 2)
	collider.shape.size = sprite.size
	pass

func move(delta: float):
	position = position + velocity * delta
	pass

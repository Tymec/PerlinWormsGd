extends Node

onready var camera = $Camera

var speed: float = 10
var position: Vector3 = Vector3(0.0, 0.0, 0.0)
var rotation: Vector3 = Vector3(0.0, 0.0, 0.0)

func _ready():
	pass

func _process(delta):
	handle_input(delta)

func handle_input(delta):
	if Input.is_key_pressed(KEY_W):
		position.x += speed * delta
	elif Input.is_key_pressed(KEY_S):
		position.x -= speed * delta
		
	if Input.is_key_pressed(KEY_A):
		rotation.y += speed * delta
	elif Input.is_key_pressed(KEY_D):
		rotation.y -= speed * delta
	
	if Input.is_key_pressed(KEY_SPACE):
		position.y += speed * delta
	elif Input.is_key_pressed(KEY_SHIFT):
		position.y -= speed * delta

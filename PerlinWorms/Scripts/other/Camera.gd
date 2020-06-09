extends Camera

export(float) var speed = 20.0
var _position: Vector3 = Vector3(0.0, 0.0, 0.0)
var _rotation: Vector3 = Vector3(0.0, 0.0, 0.0)

func _ready():
	pass

func _process(delta):
	handle_input(delta)
	transform.origin = _position
	rotation = _rotation

func handle_input(delta):
	if Input.is_key_pressed(KEY_UP):
		_position.z -= delta * speed
	elif Input.is_key_pressed(KEY_DOWN):
		_position.z += delta * speed
		
	if Input.is_key_pressed(KEY_LEFT):
		_position.x -= delta * speed
	elif Input.is_key_pressed(KEY_RIGHT):
		_position.x += delta * speed
	
	if Input.is_key_pressed(KEY_Z):
		_rotation.y += delta * speed
	elif Input.is_key_pressed(KEY_X):
		_rotation.y -= delta * speed
	
	if Input.is_key_pressed(KEY_SPACE):
		_position.y += delta * speed
	elif Input.is_key_pressed(KEY_SHIFT):
		_position.y -= delta * speed
	

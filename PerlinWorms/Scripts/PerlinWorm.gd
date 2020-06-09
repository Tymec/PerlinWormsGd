var noise: OpenSimplexNoise = OpenSimplexNoise.new()
var head_screen_pos: Vector2 = Vector2(0.0, 0.0)
#var head_noise_pos: Vector3 = Vector3(0.003417968, 0.567871093, 0.199707031)
var head_noise_pos: Vector3 = Vector3(0.0, 0.0, 0.0)
#var lateral_speed: float = 0.000244140
var lateral_speed: float = 0.001
#var segment_count: int = 112
var segment_count: int = 100
#var segment_length: float = 0.015625
var segment_length: float = 0.01
#var speed: float = 0.00146484
var speed: float = 0.001
#var thickness: float = 0.015625
var thickness: float = 0.01
#var twistiness: float = 0.015625
var twistiness: float = 0.01
var scale: float = 100.0

var MAX_SEGMENT_COUNT: int = 256
var MAX_SPEED: float = 0.5
#var MAX_LATERAL_SPEED: float = 0.0078
var MAX_LATERAL_SPEED: float = 0.01
#var MAX_THICKNESS: float = 0.0625
var MAX_THICKNESS: float = 0.1
#var MAX_TWISTINESS: float = 0.0625
var MAX_TWISTINESS: float = 0.1
var MAX_SCALE: float = 1000.0 

func _init(precision_mode: bool = false):
	noise.seed = randi()
	noise.lacunarity = 2.375
	noise.octaves = 3
	noise.persistence = 0.5
	noise.period = 1.0
	
	if precision_mode:
		enable_precision_mode()

func enable_precision_mode():
	head_noise_pos = Vector3(0.003417968, 0.567871093, 0.199707031)
	lateral_speed = 0.000244140
	segment_count = 112
	segment_length = 0.015625
	speed = 0.00146484
	thickness = 0.015625
	twistiness = 0.015625
	
	MAX_LATERAL_SPEED = 0.0078
	MAX_THICKNESS = 0.0625
	MAX_TWISTINESS = 0.0625

func update():
	var noise_value: float = noise.get_noise_3dv(head_noise_pos)
	head_screen_pos.x -= (cos(noise_value * 2.0 * PI) * speed)
	head_screen_pos.y -= (sin(noise_value * 2.0 * PI) * speed)
	
	head_noise_pos.x -= speed * 2.0
	head_noise_pos.y += lateral_speed
	head_noise_pos.z += lateral_speed
	
	head_screen_pos.x = clamp(head_screen_pos.x, -1.0, 1.0)
	head_screen_pos.y = clamp(head_screen_pos.y, -1.0, 1.0)

func draw(strip: bool = false)-> Array:
	var worm_coords: PoolVector3Array = PoolVector3Array([])
	var worm_uvs: PoolVector2Array = PoolVector2Array([])
	
	var cur_seg_screen_pos: Vector2 = head_screen_pos
	var offset_pos: Vector2 = Vector2(0.0, 0.0)
	var cur_noise_pos: Vector3 = Vector3(0.0, 0.0, 0.0)
	var cur_normal_pos: Vector2 = Vector2(0.0, 0.0)

	for cur_seg in segment_count:
		cur_noise_pos.x = head_noise_pos.x + (cur_seg * twistiness)
		cur_noise_pos.y = head_noise_pos.y
		cur_noise_pos.z = head_noise_pos.z
		var noise_val: float = noise.get_noise_3dv(cur_noise_pos)
		
		var taper_amount = get_taper_amount(cur_seg) * thickness
		
		offset_pos.x = cos(noise_val * 2.0 * PI)
		offset_pos.y = sin(noise_val * 2.0 * PI)
		
		cur_normal_pos.x = (-offset_pos.y) * taper_amount
		cur_normal_pos.y = (offset_pos.x) * taper_amount
		offset_pos.x *= segment_length
		offset_pos.y *= segment_length
		var x0: float = cur_seg_screen_pos.x + cur_normal_pos.x
		var y0: float = cur_seg_screen_pos.y + cur_normal_pos.y
		var x1: float = cur_seg_screen_pos.x - cur_normal_pos.x
		var y1: float = cur_seg_screen_pos.y - cur_normal_pos.y
		
		var z0: float = noise.get_noise_2d(x0, y0)
		var z1: float = noise.get_noise_2d(x1, y1)
			
		worm_coords.push_back(Vector3(x0 * scale, y0 * scale, z0 * scale))
		worm_uvs.push_back(Vector2(cur_seg, 0.0))
		
		if strip:
			worm_coords.push_back(Vector3(x1 * scale, y1 * scale, z1 * scale))
			worm_uvs.push_back(Vector2(cur_seg, 1.0))
		
		#glTexCoord2f ((GLfloat)curSegment, 0.0f);
		#glVertex2d (x0, y0);
		#glTexCoord2f ((GLfloat)curSegment, 1.0f);
		#glVertex2d (x1, y1);
		
		cur_seg += 1
		cur_seg_screen_pos.x += offset_pos.x
		cur_seg_screen_pos.y += offset_pos.y
	
	return [worm_coords, worm_uvs]

func get_taper_amount(segment: int)-> float:
	var cur_seg: float = segment
	var seg_count: float = segment_count
	var half_seg_count: float = seg_count / 2.0
	var base_taper_amount: float = 1.0 - abs((cur_seg / half_seg_count) - 1.0)
	return sqrt(base_taper_amount)

func set_segment_count(x: int):
	segment_count = int(clamp(x, 1, MAX_SEGMENT_COUNT))
	return segment_count

func set_speed(x: float):
	speed = clamp(x, 0.0005, MAX_SPEED)
	return speed
	
func set_lateral_speed(x: float):
	lateral_speed = clamp(x, 0.0001, MAX_LATERAL_SPEED)
	return lateral_speed

func set_thickness(x: float):
	thickness = clamp(x, 0.0030, MAX_THICKNESS)
	return thickness

func set_twistiness(x: float):
	twistiness = clamp(x, 0.0030, MAX_TWISTINESS)
	return twistiness

func set_scale(x: float):
	scale = clamp(x, 0.1, MAX_SCALE)
	return scale

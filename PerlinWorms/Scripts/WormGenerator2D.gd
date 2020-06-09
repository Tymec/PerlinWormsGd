extends Node2D

export(OpenSimplexNoise) var noise
export(SpatialMaterial) var mat
export(int) var worm_count = 10
export(bool) var poly_line = false
export(bool) var strip = true
export(bool) var precision_mode = false
export(bool) var animate = true

export var _MAX_VALUES_ = "----------"
export(float) var WORM_MAX_SEGMENT_COUNT: int = 256
export(float) var WORM_MAX_SPEED: float = 0.5
export(float) var WORM_MAX_LATERAL_SPEED: float = 0.01
export(float) var WORM_MAX_THICKNESS: float = 0.1
export(float) var WORM_MAX_TWISTINESS: float = 0.1
export(float) var WORM_MAX_SCALE: float = 1000.0 

var Worm = preload("res://Scripts/PerlinWorm.gd")
var worms = []
var worm_meshes = []
var worm_segment_count: int
var worm_speed: float
var worm_lateral_speed: float
var worm_thickness: float
var worm_twistiness: float
var worm_scale: float

func _ready():
	randomize()
	configure_noise()
	for i in range(worm_count):
		var _worm = init_worm(i)
		worms.append(_worm)
	
	# Initialized Default Variables
	worm_segment_count = worms[0].segment_count
	worm_speed = worms[0].speed
	worm_lateral_speed = worms[0].lateral_speed
	worm_thickness = worms[0].thickness
	worm_twistiness = worms[0].twistiness
	worm_scale = worms[0].scale
	
func init_worm(i):
	var worm_node = MeshInstance2D.new()
	worm_node.name = "Worm " + str(i)
	add_child(worm_node)
	worm_meshes.append(worm_node)
	
	var worm = Worm.new()
	var pos: Vector2 = Vector2(0, 0)
	pos.x = noise.get_noise_3d(i + 1000, i + 2000, i + 3000)
	pos.y = noise.get_noise_3d(i + 1001, i + 2001, i + 3001)
	worm._init(precision_mode)
	worm.head_screen_pos = pos
	
	worm.MAX_SEGMENT_COUNT = WORM_MAX_SEGMENT_COUNT
	worm.MAX_SPEED = WORM_MAX_SPEED
	worm.MAX_LATERAL_SPEED = WORM_MAX_LATERAL_SPEED
	worm.MAX_THICKNESS = WORM_MAX_THICKNESS
	worm.MAX_TWISTINESS = WORM_MAX_TWISTINESS
	worm.MAX_SCALE = WORM_MAX_SCALE
	
	return worm
	
func remove_worm():
	worms.remove(worms.size() - 1)
	worm_meshes[worm_meshes.size() - 1].queue_free()
	worm_meshes.remove(worm_meshes.size() - 1)
	
func handle_input(delta):
	# Quit
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	
	# Worm Count
	if Input.is_key_pressed(KEY_Q):
		if worm_count < 1000:
			worm_count += 1
			worms.append(init_worm(worm_count))
	elif Input.is_key_pressed(KEY_A):
		if worm_count > 0:
			worm_count -= 1
			remove_worm()
	
	# Worm Segment Count
	if Input.is_key_pressed(KEY_W):
		worm_segment_count += 1
	elif Input.is_key_pressed(KEY_S):
		worm_segment_count -= 1
	
	# Worm Speed
	if Input.is_key_pressed(KEY_E):
		worm_speed += delta
	elif Input.is_key_pressed(KEY_D):
		worm_speed -= delta
	
	# Worm Lateral Speed
	if Input.is_key_pressed(KEY_R):
		worm_lateral_speed += delta
	elif Input.is_key_pressed(KEY_F):
		worm_lateral_speed -= delta
		
	# Worm Thickness
	if Input.is_key_pressed(KEY_T):
		worm_thickness += delta
	elif Input.is_key_pressed(KEY_G):
		worm_thickness -= delta
		
	# Worm Twistiness
	if Input.is_key_pressed(KEY_Y):
		worm_twistiness += delta
	elif Input.is_key_pressed(KEY_H):
		worm_twistiness -= delta
		
	# Worm Scale
	if Input.is_key_pressed(KEY_U):
		worm_scale += 1
	elif Input.is_key_pressed(KEY_J):
		worm_scale -= 1
	
func update_worms():
	for i in range(worm_count):
		var worm = worms[i]
		
		worm_segment_count = worm.set_segment_count(worm_segment_count)
		worm_speed = worm.set_speed(worm_speed)
		worm_lateral_speed = worm.set_lateral_speed(worm_lateral_speed)
		worm_thickness = worm.set_thickness(worm_thickness)
		worm_twistiness = worm.set_twistiness(worm_twistiness)
		worm_scale = worm.set_scale(worm_scale)

func _process(delta):
	handle_input(delta)
	update_worms()
	update()
	
func draw_pline(vertices, i):
	var color = Color(1.0, (float(i) / float(worm_count)), 0.0, 1.0)
	
	var vertices2d: PoolVector2Array = PoolVector2Array([])
	for vertex in vertices:
		vertices2d.push_back(Vector2(vertex.x, vertex.y))
	draw_polyline(vertices2d, color, 1.0)
	
func draw_tri(vertices, uvs, i):
	var mesh = Mesh.new()
	var color = Color(float(worm_count * noise.get_noise_2d(i, worm_count)), (float(i) / float(worm_count)), float(i * noise.get_noise_2d(i, worm_count)), 1.0)
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	st.set_material(mat)
	
	for v in vertices.size():
		st.add_color(color)
		st.add_uv(uvs[v])
		st.add_vertex(Vector3(vertices[v].x, vertices[v].z, vertices[v].y))
	st.commit(mesh)
	
	worm_meshes[i].mesh = mesh
	
func _draw():
	for i in range(worm_count):
		var worm = worms[i].draw(strip)
		if animate:
			worms[i].update()
		
		if poly_line:
			draw_pline(worm[0], i)
		else:
			draw_tri(worm[0], worm[1], i)

func configure_noise():
	if noise.seed == 0:
		noise.seed = randi()

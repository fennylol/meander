extends CharacterBody3D

const SPEED = 2.5
const JUMP_VELOCITY = 4.5
var up_lim = PI/4 

var score: int = 0
const MAX_SCORE: int = 2

@onready var camera = $DEBUG_CAMERA
@onready var fog_shader = $FogVolume

@onready var fall_forward  : RayCast3D = $fall_zone/forward
@onready var fall_backward : RayCast3D = $fall_zone/backward
@onready var fall_left     : RayCast3D = $fall_zone/left
@onready var fall_right    : RayCast3D = $fall_zone/right

var cap = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


# ╭----------------╮
# |    UTILITY     |
# ╰----------------╯
func register_input(input_name: String, keycode: Key):
	InputMap.add_action(input_name)
	var event = InputEventKey.new()
	event.keycode = keycode
	InputMap.action_add_event(input_name, event)



func _ready():
	register_input("jump", KEY_SPACE)
	register_input("left", KEY_A)
	register_input("down", KEY_S)
	register_input("right", KEY_D)
	register_input("up", KEY_W)
	register_input("capture_mouse", KEY_ESCAPE)

# mouse
func _unhandled_input(event):
	if event is InputEventMouseMotion and cap:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, up_lim)

# mouse capture
func _process(delta):
	if Input.is_action_just_pressed("capture_mouse") or \
	Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not cap:
		cap = !cap
		if cap:Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	camera.rotation.x = clamp(camera.rotation.x, -PI/2, up_lim)
	

# movement
func _physics_process(delta):
	if !cap: return
	if not is_on_floor(): velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor(): velocity.y = JUMP_VELOCITY
	
	# ( -x, +x, -y, +y)
	var input_dir = Input.get_vector("left", "right", "up", "down")
	
	# prevent falling off ledges
	if (input_dir.y < 0 and not fall_forward.is_colliding()): input_dir.y = 0
	if (input_dir.y > 0 and not fall_backward.is_colliding()): input_dir.y = 0
	if (input_dir.x < 0 and not fall_left.is_colliding()): input_dir.x = 0
	if (input_dir.x > 0 and not fall_right.is_colliding()): input_dir.x = 0
	
	print("forward:  ", fall_forward.is_colliding())
	print("backward: ", fall_backward.is_colliding())
	print("left:     ", fall_left.is_colliding())
	print("right:    ", fall_right.is_colliding())
	print(" ")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

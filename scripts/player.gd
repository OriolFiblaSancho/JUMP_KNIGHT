extends CharacterBody2D

@onready var rayWall = $RayWall

const SPEED = 600.0
const JUMP_VELOCITY = -500.0
const WALL_PUSHBACK_X = 700
const WALL_PUSHBACK_Y = -700
const WALL_SLIDE_MAX = 300
const ACCELERATION_x = SPEED * 7 # increase to max speed in 1/7th of a second
const ACCELERATION_y = 0.05

var jumping = 0 #IS JUMPING ?
var debug_counter = 0

func _physics_process(delta: float) -> void:
	
	var direction := Input.get_axis("ui_left", "ui_right")
	
	#DEBUGGING-----------------------------------------
	print("----",debug_counter,"----")
	print("DIR - ",direction)
	print("VEL - ",velocity)
	print("JUMP - ",jumping)
	print("GRAVITY - ", get_gravity())
	debug_counter += 1
	#---------------------------------------------------	
	
	#GRAVITY HANDLING
	if not is_on_floor():
		velocity.y += move_toward(velocity.y, 2, ACCELERATION_y * delta)
	else:
		if jumping != 0:
			jumping = 0 #Reset jumping when touching ground
	
	
	#HANDLES JUMP THINGS
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():		#HANDLES JUMP
			velocity.y = JUMP_VELOCITY
			jumping = 1
		elif wall_colider():	#HANDLES WALL JUMP
			wall_jump(get_wall_normal())
		elif jumping == 1:		#HANDLES DOUBLE JUMP
			double_jump()
	
			
	#WALL SLIDING
	if wall_colider():
		wall_sliding()
		
	#HANDLE X DIRECTION
	if direction == 1:
		rayWall.scale.x = 1
	elif direction == -1:
		rayWall.scale.x = -1
		
	
	
	velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION_x * delta)

	move_and_slide()
	
	
#RAYCAST FUNC TO SEE IF IS COLLIDING WITH A WALL
func wall_colider():
	return rayWall.is_colliding()

#DOUBLE JUMP FUNC
func double_jump():
	velocity.y = JUMP_VELOCITY
	jumping = 0
	
#WALL JUMP FUNC
func wall_jump(wall_normal):
	velocity.x = wall_normal.x * WALL_PUSHBACK_X
	velocity.y = WALL_PUSHBACK_Y

#WALL SLIDING FUNC
func wall_sliding():
	velocity.y = min(velocity.y, WALL_SLIDE_MAX)
	jumping = 1

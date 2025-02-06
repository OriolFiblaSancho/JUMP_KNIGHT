extends CharacterBody2D

@onready var rayWall = $RayWall
@onready var coyote_time = $CoyoteTime

const SPEED = 600.0
const JUMP_VELOCITY = -800.0
const WALL_PUSHBACK_X = 700
const WALL_PUSHBACK_Y = -900
const WALL_SLIDE_MAX = 300
const ACCELERATION_x = SPEED * 7 # increase to max speed in 1/7th of a second
const ACCELERATION_y =200
const MAX_ACCELERATION_y = 2000

var jumping = 0 #IS JUMPING ?
var fall_acceleration = 0.0 #stores fall acc
var debug_counter = 0

func _physics_process(delta: float):

	var direction := Input.get_axis("ui_left", "ui_right")
	var was_on_floor = is_on_floor()
	
	# GRAVITY HANDLING
	if not is_on_floor():
		#Calculates acceleration and add it to the var
		fall_acceleration = min(fall_acceleration + ACCELERATION_y * delta * 100, MAX_ACCELERATION_y)
		velocity.y += (500 + fall_acceleration) * delta
	else:
		fall_acceleration = 0  # Resetear aceleración al tocar el suelo
		if jumping != 0:
			jumping = 0  # Reset jumping when touching ground
	
	
	#HANDLES JUMP THINGS
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor() || !coyote_time.is_stopped():	#HANDLES JUMP and coyote time
			velocity.y = JUMP_VELOCITY
			jumping = 1
		elif wall_colider():	#HANDLES WALL JUMP
			wall_jump(get_wall_normal())
		elif jumping == 1:		#HANDLES DOUBLE JUMP
			pass
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
	
	#Check if it was on floor after move_and_slide()
	if was_on_floor && !is_on_floor():
		coyote_time.start()
		
	#DEBUGGING-----------------------------------------
	print("----",debug_counter,"----")
	print("DIR - ",direction)
	print("VEL - ",velocity)
	print("JUMP - ",jumping)
	print("WAS - ", was_on_floor)
	print("IS - ",is_on_floor())
	if coyote_time.is_stopped():
		print("COYOTE - STOPED")
	else:
		print("COYOTE - RUNNING")
	debug_counter += 1
	#---------------------------------------------------	
	
#RAYCAST FUNC TO SEE IF IS COLLIDING WITH A WALL
func wall_colider():
	return rayWall.is_colliding()

#DOUBLE JUMP FUNC
func double_jump():
	velocity.y = JUMP_VELOCITY
	jumping = 0
	fall_acceleration = 0
#WALL JUMP FUNC
func wall_jump(wall_normal):
	velocity.x = wall_normal.x * WALL_PUSHBACK_X
	velocity.y = WALL_PUSHBACK_Y

#WALL SLIDING FUNC
func wall_sliding():
	velocity.y = min(velocity.y, WALL_SLIDE_MAX)
	jumping = 1

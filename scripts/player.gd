extends CharacterBody2D

@onready var rayWall = $RayWall

const SPEED = 600.0
const JUMP_VELOCITY = -500.0
const WALL_PUSHBACK_X = 2000
const WALL_PUSHBACK_Y = -400
const WALL_SLIDE_MAX = 200

var jumping = 0
var debug_counter = 0

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	var wall_normal = get_wall_normal()
	
	#DEBUGGING-----------------------------------------
	print("----",debug_counter,"----")
	print("DIR - ",direction)
	print("VEL - ",velocity)
	print("JUMP - ",jumping)
	debug_counter += 1
	#---------------------------------------------------	
	
	#GRAVITY HANDLING
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumping = 0 #Reset jumping when touching ground
	
	
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			jumping = 1
		elif wall_colider():
			velocity = wall_normal * WALL_PUSHBACK_X
			velocity.y = WALL_PUSHBACK_Y
		elif jumping == 1:
			velocity.y = JUMP_VELOCITY
			jumping = 0
	
			
	#WALL SLIDING
	if wall_colider():
		velocity.y = min(velocity.y, WALL_SLIDE_MAX)
		jumping = 1
		
	#HANDLE X DIRECTION
	if direction:
		velocity.x = direction * SPEED
		if direction == 1:
			rayWall.scale.x = 1
		elif direction == -1:
			rayWall.scale.x = -1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


	move_and_slide()

func wall_colider():
	return rayWall.is_colliding()

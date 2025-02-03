extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -500.0
const WALL_PUSHBACK_X = 1800
const WALL_PUSHBACK_Y = -600
const WALL_SLIDE_MAX = 50

var jumping = 0
var debug_counter = 0

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	var wall_normal = get_wall_normal()
	
	#DEBUGGING-----------------------------------------
	print("----",debug_counter,"----")
	print("VEL X - ",velocity.x)
	print("VEL Y - ",velocity.y)
	print("JUMP - ",jumping)
	print("WALL_X - ", wall_normal.x)
	if is_on_wall_only():
		print("WALL - TRUE")
	else:
		print("WALL - FALSE")
	debug_counter += 1
	#---------------------------------------------------
	
	#GRAVITY HANDLING
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumping = 0 #Reset jumping when touching ground
	

	#WALL SLIDING
	if is_on_wall_only():
		velocity.y = min(velocity.y, WALL_SLIDE_MAX)
		
		#IF IS ON WALL AND "JUMP":
		if Input.is_action_just_pressed("ui_accept"):
			# Push player away from the wall
			velocity.x = wall_normal.x * WALL_PUSHBACK_X
			velocity.y = WALL_PUSHBACK_Y
			jumping = 1
			
	#JUMP HANDLING
	elif Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumping = 1
	
	#DOUBLE JUMP HANDLING
	elif Input.is_action_just_pressed("ui_accept") and jumping == 1:
		velocity.y = JUMP_VELOCITY
		jumping = 0

	#HANDLE X DIRECTION
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

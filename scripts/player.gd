extends CharacterBody2D

@onready var playerSprite = $AnimatedSprite2D
@onready var playerAnim = $anim
@onready var rayWall = $RayWall
@onready var coyote_time = $CoyoteTime
@onready var heartsContainer = $CanvasLayer/heartsCont
@onready var hurtBoxCol = $hurtBox/CollisionShape2D
@onready var dashTimer = $dashAgain
@onready var dashingTimer = $dashing
@onready var attackArea = $attackArea
@onready var attackCol = $attackArea/CollisionShape2D
@onready var attackTimer = $attack

signal healthChanged
	
const SPEED = 600.0
const JUMP_VELOCITY = -800.0
const WALL_PUSHBACK_X = 700
const WALL_PUSHBACK_Y = -900
const WALL_SLIDE_MAX = 300
const ACCELERATION_x = SPEED * 7 # increase to max speed in 1/7th of a second
const ACCELERATION_y =200
const MAX_ACCELERATION_y = 2000
const MAXHEALTH = 5

var jumping = 0 #IS JUMPING ?
var fall_acceleration = 0.0 #stores fall acc
var debug_counter = 0
var last_dir = 1
var dashing = false
var canDash = true
var currentHealth = 5 #stores the actual health
var defaultSprite = preload("res://assets/icon.svg")
var attacking = false

var currentState = playerStates.IDLE
enum playerStates {IDLE, RUN, SWORD, JUMP, DASH, ATTACK, FALLING}

func _ready():
	heartsContainer.setMaxHeart(MAXHEALTH)
	heartsContainer.updateHeart(currentHealth)
	healthChanged.connect(heartsContainer.updateHeart)
	
func _physics_process(delta: float):
	match currentState:
		playerStates.IDLE:
			playerAnim.play("idle")
		playerStates.RUN:
			playerAnim.play("run")
		playerStates.JUMP:
			playerAnim.play("roll")
		playerStates.DASH:
			playerAnim.play("roll")
		playerStates.ATTACK:
			playerAnim.play("attack")
		playerStates.FALLING:
			playerAnim.play("idle")
			
	var direction := Input.get_axis("ui_left", "ui_right")
	var was_on_floor = is_on_floor()
	var falling = velocity.y 
	
	if direction != 0:
		last_dir = direction
	
	
	# GRAVITY HANDLING
	if not is_on_floor() and !dashing:
		#Calculates acceleration and add it to the var
		fall_acceleration = min(fall_acceleration + ACCELERATION_y * delta * 100, MAX_ACCELERATION_y)
		velocity.y += (500 + fall_acceleration) * delta
	else:
		fall_acceleration = 0  # Resetear aceleración al tocar el suelo
		jumping = 0  # Reset jumping when touching ground
			
	
	if attacking:
		currentState = playerStates.ATTACK
	elif Input.is_action_just_pressed("attack") and !attacking:
		attack()
	elif is_on_floor() and !dashing:
		if direction:
			currentState = playerStates.RUN
		else:
			currentState = playerStates.IDLE
	elif velocity.y < 0 and !is_on_floor() and !dashing:
		currentState = playerStates.JUMP
	elif velocity.y > 0 and !is_on_floor() and !dashing:
		currentState = playerStates.FALLING
	elif dashing:
		currentState = playerStates.DASH

	
	#HANDLES JUMP THINGS
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() || !coyote_time.is_stopped():	#HANDLES JUMP and coyote time
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
	if last_dir == 1:
		playerSprite.flip_h = true
	elif last_dir == -1:
		playerSprite.flip_h = false
		
	
	dash()

	
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
	print("CURRENT - ", currentState)
	print("ATTACK -", attacking)
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

#DAMAGE FUNC
func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.name == "damageArea" and hurtBoxCol.disabled == false:
		currentHealth -= 1
		if currentHealth < 0:
			currentHealth = MAXHEALTH
		healthChanged.emit(currentHealth) #Emits the actual health to the counter
		knockBack()
		frameFreeze()
		#Sin esto inmortalHit superpone al frameFreeze
		await get_tree().create_timer(0.2, true, false, true).timeout
		inmortalHit() 
		
#knockBack FUNC	
func knockBack():
	var direction := Input.get_axis("ui_left", "ui_right")
	#Note for the future: May have problems when usign moving spikes with this
	#if the player doesn't move it will not have knockback so this should use the
	#spike vel: https://youtu.be/SNWpFTer-YU?si=ajyiO5ZoL9CPfGBG
	var knockBackVel = Vector2(1200*(last_dir*-1) ,-600)
	var knockBackDir = knockBackVel
	jumping = 1
	velocity = knockBackDir
	move_and_slide()

#frameFreeze FUNC
func frameFreeze():
	Engine.time_scale = 0
	playerSprite.self_modulate = Color(255,255,255,1)
	await get_tree().create_timer(0.20, true, false, true).timeout
	Engine.time_scale = 1
	playerSprite.self_modulate = Color("ffffff",1)

#inmortalHit FUNC
func inmortalHit():
	playerSprite.self_modulate = Color("ffffff",1)
	hurtBoxCol.disabled = true
	var original_color = playerSprite.self_modulate
	var tween = create_tween().set_loops()
	
	tween.tween_callback(playerSprite.set_self_modulate.bind(Color(255,255,255,0.5)))
	tween.tween_interval(0.1)
	tween.tween_callback(playerSprite.set_self_modulate.bind(original_color))
	tween.tween_interval(0.1)
	
	await get_tree().create_timer(0.7).timeout
	tween.kill()
	playerSprite.self_modulate = original_color
	hurtBoxCol.disabled = false

func dash():
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		last_dir = direction
		
	if Input.is_action_just_pressed("dash") and canDash:

		dashing = true
		canDash = false
		dashingTimer.start()
		dashTimer.start()
		
		var dashVel = Vector2(2000 * last_dir, 0)
		velocity = dashVel
		

func _on_dash_again_timeout() -> void:
	canDash = true

func _on_dashing_timeout() -> void:
	dashing = false


func attack():
	var direction := Input.get_axis("ui_left", "ui_right")
	attacking = true
	velocity.x = 0  # Stop horizontal movement briefly
	if direction != 0:
		last_dir = direction
	# Check if attacking upward
	if Input.is_action_pressed("ui_up"):
		attackCol.position = Vector2(0, -50)  # Move hitbox above
		attackCol.rotation_degrees = 90  # No need to rotate

	# Check if attacking downward (only in air)
	elif Input.is_action_pressed("ui_down") and !is_on_floor():
		attackCol.position = Vector2(0, 50)  # Move hitbox below
		attackCol.rotation_degrees = 90
		
		
	# Default attack (left or right)
	else:
		# Use last_dir if no movement input
		if last_dir == 1:
			attackCol.position = Vector2(40, 0)  # Attack to the right
			attackCol.rotation_degrees = 0
		elif last_dir == -1:
			attackCol.position = Vector2(-40, 0)  # Attack to the left
			attackCol.rotation_degrees = 0
	
	attackCol.set_deferred("disabled", false)  # Enable hitbox
	attackTimer.start()

		
func _on_attack_timeout() -> void:
	attacking = false
	attackCol.set_deferred("disabled", true)  # Disable hitbox
	attackCol.position = Vector2(0, 0)  # Reset hitbox position

	# Return to the correct state
	if !is_on_floor():
		if velocity.y < 0:
			currentState = playerStates.JUMP
		else:
			currentState = playerStates.FALLING
	else:
		if Input.get_axis("ui_left", "ui_right") != 0:
			currentState = playerStates.RUN
		else:
			currentState = playerStates.IDLE

func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.name == "damageArea" and !attackCol.disabled:
		# Only bounce if the player is attacking downward (so pogo effect is relevant)
		if velocity.y > 0:  # Ensure you're falling (attacking downward)
			velocity.y = -600

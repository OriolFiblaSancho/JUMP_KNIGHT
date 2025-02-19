extends CharacterBody2D

@onready var camera = $Camera2D
@onready var playerSprite = $AnimatedSprite2D
@onready var playerAnim = $anim
@onready var rayWall = $RayWall
@onready var coyote_time = $CoyoteTime
@onready var hurtBoxCol = $hurtBox/CollisionShape2D
@onready var dashTimer = $dashAgain
@onready var dashingTimer = $dashing
@onready var attackArea = $attackArea
@onready var attackCol = $attackArea/CollisionShape2D
@onready var attackTimer = $attack
@onready var ActiveBoxContainer = $mechanicsActive/BoxContainer
@onready var DemoDashBoxSprite = $CanvasLayer/BoxContainer/DemoDashBox
@onready var DemoDoubleJumpBoxSprite = $CanvasLayer/BoxContainer/DemoDoubleJumpBox
@onready var DemoWallJumpingBoxSprite = $CanvasLayer/BoxContainer/DemoWallJumpingBox
@onready var attackSprite = $AnimatedSprite2D/attackSprite
@onready var walkingParticles = $walkingParticles
@onready var deathParticles = $deathParticles

@export var cameraLimitLeft: int = 0
@export var cameraLimitRight: int = 0
@export var cameraLimitTop: int = 0
@export var cameraLimitBottom: int = 0

signal healthChanged
	
const SPEED = 600.0
const JUMP_VELOCITY = -800.0
const WALL_PUSHBACK_X = 700
const WALL_PUSHBACK_Y = -900
const WALL_SLIDE_MAX = 300
const ACCELERATION_x = SPEED * 7 # increase to max speed in 1/7th of a second
const ACCELERATION_y =200
const MAX_ACCELERATION_y = 2000
const MAXHEALTH = 1
const ATTACK_KNOCKBACK = 500

var jumping = 0 #IS JUMPING ?
var fall_acceleration = 0.0 #stores fall acc
var debug_counter = 0
var last_dir = 1
var dashing = false
var canDash = true
var currentHealth = 1 #stores the actual health
var defaultSprite = preload("res://assets/icon.svg")
var attacking = false
var canDoubleJump = false
var currentState = playerStates.IDLE
var colisionCheck = false
var healtCheck = false

var doubleJumpActive = false
var wallJumpActive = false
var dashActive = false

var checkpoint = Vector2(0,0)

enum playerStates {IDLE, RUN, SWORD, JUMP, DASH, ATTACK, FALLING}

var canMove = true

func _ready():
	
	DemoWallJumpingBoxSprite.hide()
	DemoDoubleJumpBoxSprite.hide()
	DemoDashBoxSprite.hide()
	
	attackSprite.hide()
	
	walkingParticles.emitting = false
	deathParticles.emitting = false
	
	camera.limit_left = cameraLimitLeft
	camera.limit_right = cameraLimitRight
	camera.limit_top = cameraLimitTop
	camera.limit_bottom = cameraLimitBottom
	camera.limit_smoothed = true

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
	
	if is_on_floor() and abs(velocity.x) > 10 and currentState != playerStates.DASH:
		walkingParticles.emitting = true
	else:
		walkingParticles.emitting = false
	
	# GRAVITY HANDLING
	if not is_on_floor() and !dashing:
		#Calculates acceleration and add it to the var
		fall_acceleration = min(fall_acceleration + ACCELERATION_y * delta * 100, MAX_ACCELERATION_y)
		velocity.y += (500 + fall_acceleration) * delta
	else:
		fall_acceleration = 0  # Resetear aceleración al tocar el suelo
		jumping = 0  # Reset jumping when touching ground
		canDoubleJump = false
			
	
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
			canDoubleJump = true
		elif wall_colider():	#HANDLES WALL JUMP
			if wallJumpActive:
				wall_jump(get_wall_normal())
			else:
				pass
		elif canDoubleJump:		#HANDLES DOUBLE JUMP
			if doubleJumpActive:
				double_jump()
			else:
				pass
		else:
			pass
	
			
	#WALL SLIDING
	if wall_colider():
		wall_sliding()
		
	#HANDLE X DIRECTION
	if direction == 1:
		rayWall.scale.x = 1
		
	elif direction == -1:
		rayWall.scale.x = -1
		
		
	if canMove:
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
		canDoubleJump = true
	

		
	#DEBUGGING-----------------------------------------
	print("----",debug_counter,"----")
	print("DIR - ",direction)
	print("VEL - ",velocity)
	print("CAN 2 JUMP - ",canDoubleJump)
	print("WAS - ", was_on_floor)
	print("IS - ",is_on_floor())
	print("CURRENT - ", currentState)
	print("ATTACK -", attacking)
	print("Position -", position)
	debug_counter += 1
	#---------------------------------------------------	
	
#RAYCAST FUNC TO SEE IF IS COLLIDING WITH A WALL
func wall_colider():
	return rayWall.is_colliding()

#DOUBLE JUMP FUNC
func double_jump():
	velocity.y = JUMP_VELOCITY
	canDoubleJump = false
	fall_acceleration = 0
	
#WALL JUMP FUNC
func wall_jump(wall_normal):
	velocity.x = wall_normal.x * WALL_PUSHBACK_X
	velocity.y = WALL_PUSHBACK_Y

#WALL SLIDING FUNC
func wall_sliding():
	velocity.y = min(velocity.y, WALL_SLIDE_MAX)
	jumping = 1
	canDoubleJump = true

#DAMAGE FUNC
func _on_hurt_box_area_entered(area: Area2D) -> void:
	if hurtBoxCol.disabled == false and healtCheck == false:
		if area.name == "damageArea":
			healtCheck = true
			currentHealth -= 1
			if currentHealth <= 0:
				
				#knockBack()
				frameFreeze()
				#Sin esto inmortalHit superpone al frameFreeze
				await get_tree().create_timer(0.2, true, false, true).timeout
				inmortalHit()
				healtCheck = false
				position = checkpoint
			
		elif area.name == "restartArea":
			healtCheck = true
			currentHealth -= 1
			if currentHealth <= 0:
				canMove = false
				velocity.x = 0
				currentHealth = MAXHEALTH
				deathParticles.emitting = true
				await get_tree().create_timer(0.8, true, false, true).timeout
				deathParticles.emitting = false
				position = checkpoint
				canMove = true
			#knockBack()
			frameFreeze()
			#Sin esto inmortalHit superpone al frameFreeze
			
			await get_tree().create_timer(0.2, true, false, true).timeout
			
			inmortalHit()
			healtCheck = false
		
		
#knockBack FUNC	
func knockBack():
	var direction := Input.get_axis("ui_left", "ui_right")
	#Note for the future: May have problems when usign moving spikes with this
	#if the player doesn't move it will not have knockback so this should use the
	#spike vel: https://youtu.be/SNWpFTer-YU?si=ajyiO5ZoL9CPfGBG
	var knockBackVel = Vector2(1200*(last_dir*-1) ,-600)
	var knockBackDir = knockBackVel
	jumping = 1
	canDoubleJump = true
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
	if dashActive:
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
	else:
		pass
		

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
		attackCol.rotation_degrees = 0  # No need to rotate
		attackSprite.position = Vector2(0, -50)  # Attack to the left
		if !attackSprite.flip_h:
			attackSprite.rotation_degrees = -90
		else:
			attackSprite.rotation_degrees = 90
	
	# Check if attacking downward (only in air)
	elif Input.is_action_pressed("ui_down") and !is_on_floor():
		attackCol.position = Vector2(0, 50)  # Move hitbox below
		attackCol.rotation_degrees = 0
		attackSprite.position = Vector2(0, 50)  # Move hitbox below
		if attackSprite.flip_h:
			attackSprite.rotation_degrees = -90
		else:
			attackSprite.rotation_degrees = 90
	# Default attack (left or right)
	else:
		# Use last_dir if no movement input
		if last_dir == 1:
			attackCol.position = Vector2(40, 0)  # Attack to the right
			attackCol.rotation_degrees = 90
			attackSprite.flip_h = false
			attackSprite.position = Vector2(40, 0)  # Attack to the right
			attackSprite.rotation_degrees = 0
		elif last_dir == -1:
			attackCol.position = Vector2(-40, 0)  # Attack to the left
			attackCol.rotation_degrees = 90
			attackSprite.flip_h = true
			attackSprite.position = Vector2(-40, 0)  # Attack to the left
			attackSprite.rotation_degrees = 0
	
	attackCol.set_deferred("disabled", false)  # Enable hitbox
	attackTimer.start()
	attackSprite.show()
		
func _on_attack_timeout() -> void:
	attacking = false
	attackCol.set_deferred("disabled", true)  # Disable hitbox
	attackCol.position = Vector2(0, 0)  # Reset hitbox position
	attackSprite.hide()
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
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		last_dir = direction
	
	if area.name == "damageArea" and !attackCol.disabled and colisionCheck == false:
		canDoubleJump = true
		colisionCheck = true
		# Only bounce if the player is attacking downward (so pogo effect is relevant)
		if velocity.y > 0 and Input.is_action_pressed("ui_down"):  # Downward attack (pogo)
			velocity.y = -ATTACK_KNOCKBACK * 1.2
		elif Input.is_action_pressed("ui_up"):  # Upward attack, no knockback applied
			pass
		elif !Input.is_action_pressed("ui_down"):  # Regular attack, apply horizontal knockback
			if last_dir == 1:
				velocity.x = -ATTACK_KNOCKBACK
			elif last_dir == -1:
				velocity.x = ATTACK_KNOCKBACK

		colisionCheck = false

func _on_interact_area_area_entered(area: Area2D) -> void:
	
	if area.name == "demoDoubleJumpBoxArea":
		doubleJumpActive = true
		DemoDoubleJumpBoxSprite.show()
	elif area.name == "demoWallJumpBoxArea":
		wallJumpActive = true
		DemoWallJumpingBoxSprite.show()
	elif area.name == "demoDashBoxArea":
		dashActive = true
		DemoDashBoxSprite.show()
	elif area.name == "checkpointCol":
		checkpoint = area.global_position

extends CharacterBody2D


const speed = 550.0
const jump_power = -1500.0
const acc = 50
const friction = 70
const gravity = 120
const wall_jump_pushback = 300
const wall_slide_gravity = 100

#Wall sliding variable
var is_wall_sliding = false

#So that the player can't climb one wall indefinitely, must bounce between 2 walls
var whichWallAreYouOn = "none"

#So the player doesn't bounce off of walls when they faceplant into them
var jumpCooldown = 0.2


func _physics_process(delta):
	var input_dir: Vector2 = input()
	
	if input_dir != Vector2.ZERO:
		accelerate(input_dir)
		$AnimationPlayer.play("Walk")
	else:
		add_friction()
		$AnimationPlayer.play("Idle")
		
	#calls move_and_slide, we really don't need this function but w.e
	player_movement()
	
	#sees if the player is jumping
	jump()
	
	#sees if the player is sliding down a wall
	wall_slide(delta)
	
	#See comment about jumpCooldown
	jumpCooldown -= delta
	if jumpCooldown <= 0:
		jumpCooldown = 0

#I really don't understand move and slide, but...
#it needs to be called for the game to process the physics
func player_movement():
	move_and_slide()

#Acceleration function so you don't turn exactly on a dime
func accelerate(direction):
	velocity = velocity.move_toward(speed * direction, acc)
	
#Little bit of friction so you don't turn on a dime
func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, friction)

func input() -> Vector2:
	var input_dir = Vector2.ZERO
	
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir = input_dir.normalized()
	return input_dir
	
	
func jump():
	
	#Make the character fall due to gravity,
	velocity.y += gravity
	
	#If you are trying to jump off the wall
	if is_on_wall() and Input.is_action_pressed("ui_select") and !is_on_floor():
		
		#If hugging the left wall, push off to the right
		if Input.is_action_pressed("ui_left") and jumpCooldown == 0:
			velocity.y = jump_power
			velocity.x = wall_jump_pushback
			#establish that we are on left wall so that we can't jump on left wall to climb upwards
			whichWallAreYouOn = "left"
			
			
		
		#if hugging the right wall, push off to the left
		elif Input.is_action_pressed("ui_right") and jumpCooldown == 0:
			velocity.y = jump_power
			velocity.x = -wall_jump_pushback
			#establish that we are on right wall so that we can't jump on left wall to climb upwards
			whichWallAreYouOn = "right"
			
	#Basic Jump from the floor
	elif is_on_floor() and Input.is_action_pressed("ui_select"):
		velocity.y = jump_power
		
		#remind engine to reset the wall that the player is on
		whichWallAreYouOn = "none"
		
		#So that the player doesn't immediately bounce off the wall when they faceplant into wall
		jumpCooldown = 0.2

#Allows player to slowly fall when hanging onto a wall
func wall_slide(delta):
	#If you are on the wall
	if is_on_wall() and !is_on_floor():
		if Input.is_action_pressed("ui_left") and whichWallAreYouOn != "left":
			is_wall_sliding = true
		elif Input.is_action_pressed("ui_right") and whichWallAreYouOn != "right":
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false
	
	if is_wall_sliding:
		velocity.y += (wall_slide_gravity * delta)
		velocity.y = min(velocity.y, wall_slide_gravity)
		
		
		


#extends CharacterBody2D
#
#
#const SPEED = 300.0
#const JUMP_VELOCITY = -600.0
#var jumpCooldown = 0
#var is_wall_sliding = false;
#
#
## Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#var wall_slide_gravity = gravity * 0.5
#
#func jump():
		#var direction = Input.get_axis("ui_left", "ui_right")
		#if Input.is_action_just_pressed("ui_select") and is_on_floor() and jumpCooldown <= 0:
			#velocity.y = JUMP_VELOCITY
			#jumpCooldown = 0.25
		#
		#if Input.is_action_just_pressed("ui_select") and is_on_wall() and jumpCooldown <= 0:
			#velocity.y = JUMP_VELOCITY
			#jumpCooldown = 0.25
			#
		#
		#
#
#func wall_slide(delta):
	#if is_on_wall() and !is_on_floor():
		#if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
			#is_wall_sliding = true
		#else:
			#is_wall_sliding = false
	#else:
		#is_wall_sliding = false
	#
	#if is_wall_sliding:
		#velocity.y += (wall_slide_gravity * delta)
		#velocity.y = min(velocity.y, wall_slide_gravity)
#
#func _process(delta):
	#if jumpCooldown >= 0:
		#jumpCooldown -= delta
#
#func _physics_process(delta):
	## Add the gravity.
	#if not is_on_floor():
		#velocity.y += gravity * delta * 2
#
	##Call jump function
	#jump()
	#
	#
	##if is_on_wall_only() and 
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction = Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()



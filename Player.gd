extends CharacterBody2D

# originally did not have denominators
const speed = 550.0/3
const jump_power = -2000.0/2

const acc = 50
const friction = 70

#const gravity = 60

const wall_jump_pushback = 300

# mine
const SPEED = 250.0
const WALK_SPEED = 300.0
const JUMP_HEIGHT = 600
var gravity = 45.0
var canDash = true
var dashing = false
var canDoubleJump = false
var screen_size
var facing
###


const wall_slide_gravity = 100
var is_wall_sliding = false
var onFloor = true
var whichWallAreYouOn = "none"
@onready var all_interactions = [] # store interactions in an array
func _ready():
	screen_size = get_viewport_rect().size
	
func dash(face):
	var dashDirection = Vector2.ZERO

	if face == "left":
		dashDirection = Vector2(-1,0)
	else:
		dashDirection = Vector2(1,0)
		
	if Input.is_action_just_pressed("dash") and canDash:
		# could add logic for left or right dash animation
		velocity = dashDirection.normalized()*1500
		canDash = false
		dashing = true
		await get_tree().create_timer(1.0).timeout
		canDash = true
		dashing = false
		
func wallCling():
	if is_on_wall() and (Input.is_action_pressed("right") || Input.is_action_pressed("left")):
		var wall_normal = get_wall_normal()
		velocity.y = 0 # THIS LINE MESSES WITH JUMPING, IT MAKES IT DIFFICULT TO JUMP OFF A WALL. FIX THIS SO THE MOVEMENT IS BETTER
		if wall_normal.x > 0:
			print("Character is hugging a wall to the left")
		elif wall_normal.x < 0:
			print("Character is hugging a wall to the right")


func _physics_process(delta):
	velocity.y += gravity

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() || !canDoubleJump):
		$MovementAnimations.stop()
		$MovementAnimations.play("jump") # jump animation is tweaking 
		velocity.y = -JUMP_HEIGHT
		if !is_on_floor():
			canDoubleJump = true
	#if is_on_wall() and Input.is_action_just_pressed("up"):
		#if Input.is_action_pressed("left"):
			#velocity.y = -JUMP_HEIGHT
			#velocity.x = 200
		#elif Input.is_action_pressed("left"):
			#velocity.y = -JUMP_HEIGHT
			#velocity.x = -200
	#elif Input.is_action_just_pressed("up") and (is_on_floor() || !canDoubleJump):
		#velocity.y = -JUMP_HEIGHT
		#if !is_on_floor():
			#canDoubleJump = true
		
	# reset double jump once you are on a floor
	if is_on_floor():
		canDoubleJump = false

	# Left and right movement
	if Input.is_action_pressed("left"):
		velocity.x = -WALK_SPEED
		if is_on_floor():
			$MovementAnimations.play("walk")
		facing = "left"
		$Sprite2D.flip_h = true
	elif Input.is_action_pressed("right"):
		velocity.x = WALK_SPEED
		if is_on_floor():
			$MovementAnimations.play("walk")	
		facing = "right"
		$Sprite2D.flip_h = false
	else:
		velocity.x = move_toward(velocity.x,0,SPEED) # this adds slow down so that the player doesnt slide when direction is let go
		if is_on_floor():
			$MovementAnimations.play("idle")
			
		
	# this logic should maybe be made into a function or something that is reusable
	# this should just use the primary item, and play its animation 
	

	dash(facing)
	wallCling()


	move_and_slide()

#
#func _physics_process(delta):
	#var input_dir: Vector2 = input()
	#
	#if input_dir != Vector2.ZERO:
		#if is_on_floor():
			#$MovementAnimations.play("walk")
		#accelerate(input_dir)
		#
		#if input_dir < Vector2.ZERO:
			#$Sprite2D.flip_h = true
		#else:
			#$Sprite2D.flip_h = false
	#else:
		#if is_on_floor():
			#$MovementAnimations.play("idle")
		#add_friction()
		#
	#yapper()
	#jump()
	#wall_slide(delta)
	#move_and_slide()


func yapper(): # yaps in terminal
	if is_on_wall():
		var wall_normal = get_wall_normal()
		if wall_normal.x > 0:
			print("Character is hugging a wall to the left")
		elif wall_normal.x < 0:
			print("Character is hugging a wall to the right")


#func player_movement():
	#move_and_slide()

#Acceleration function so you don't turn exactly on a dime
#func accelerate(direction):
	#velocity = velocity.move_toward(speed * direction, acc)
	#
##Little bit of friction so you don't turn on a dime
#func add_friction():
	#velocity = velocity.move_toward(Vector2.ZERO, friction)
#
#func input() -> Vector2:
	#var input_dir = Vector2.ZERO
	#
	#input_dir.x = Input.get_axis("left", "right")
	#input_dir = input_dir.normalized()
	#return input_dir
	
func jump():
	#Make the character fall due to gravity
	velocity.y += gravity
	
	#If hugging the left wall, push off to the right
	if is_on_wall() and Input.is_action_pressed("jump") and !is_on_floor():
		if Input.is_action_pressed("left"):
			velocity.y = jump_power
			velocity.x = wall_jump_pushback
			whichWallAreYouOn = "left"

			
		
		#if hugging the right wall, push off to the left
		elif Input.is_action_pressed("right"):
			velocity.y = jump_power
			velocity.x = -wall_jump_pushback
			whichWallAreYouOn = "right"

						
			
	#Basic Jump
	elif is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_power
		whichWallAreYouOn = "none"
		$MovementAnimations.play("jump")

	

func wall_slide(delta):
	if is_on_wall() and !is_on_floor():
		if Input.is_action_pressed("left") and whichWallAreYouOn != "left":
			is_wall_sliding = true
		elif Input.is_action_pressed("right") and whichWallAreYouOn != "right":
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false
	
	if is_wall_sliding:
		velocity.y += (wall_slide_gravity * delta)
		velocity.y = min(velocity.y, wall_slide_gravity)
		
	
		



################
# INTERACTIONS #
################
func _on_interaction_area_area_entered(area):
	if Input.is_action_pressed("interact"): # change this as its funky right now
		all_interactions.insert(0,area) # store an interaction
		updateInteractions()


func _on_interaction_area_area_exited(area):
	all_interactions.erase(area) # remove an interaction
	updateInteractions()


func updateInteractions():
	if all_interactions:
		$"Interactions/InteractLabel".text = all_interactions[0].interact_label
		print(all_interactions[0].interact_label)
	else:
		$"Interactions/InteractLabel".text = ""

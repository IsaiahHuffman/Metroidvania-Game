extends CharacterBody2D


const speed = 400.0/2
const jump_power = -1000 #-1500.0/2
const acc = 50
const friction = 70
const gravity = 90
const wall_jump_pushback = 300
const wall_slide_gravity = 100

#for coyote jump/time
const minCoyoteVelocity = 120
const maxCoyoteVelocity = 450

var coyoteJumpCounter = 0

#Dashing variables
var canDash = true
var dashing = false
var lastFacedDirection = "none"
var direction = 1

@onready var all_interactions = [] # store interactions in an array

#The following variables are all used for jump() and wall_slide()
#To enable doubleJump mechanics
var canDoubleJump = true
#So that the jump animation doesn't get clobbered by other animations, e.g. walk and idle
var isJumping = false
#Wall sliding variable
var is_wall_sliding = false
#So that the player can't climb one wall indefinitely, must bounce between 2 walls
var whichWallAreYouOn = "none"
#So the player doesn't bounce off of walls when they faceplant into them
var jumpCooldown = 0.2

#func _process(delta):
	#self.global_position = get_global_mouse_position()
	#if $Au

#Main gameplay loop
func _physics_process(delta):
	var input_dir: Vector2 = input()
	#print ("velocity: ", velocity.y)
	
	
	#if in the middle of the air (jumping between walls), play the animation
	#if !is_on_floor() and !is_on_wall():
		#$AnimationPlayer.play("jumpBetweenWalls")
	# UNCOMMENT ABOVE
	
	#If we move left or right
	if input_dir != Vector2.ZERO:
		accelerate(input_dir)
		
		#Change character direction when they run different directions
		direction = Input.get_axis("left", "right")
		if direction == -1:
			get_node("Sprite2D").flip_h = true
		elif direction == 1:
			get_node("Sprite2D").flip_h = false
		
		#Only play walking animation if we are on the ground and not in midjump
		if is_on_floor() and isJumping == false:
			$AnimationPlayer.play("walk")
		
	#If we're not inputting left or right movement
	else:
		add_friction()
		
		#Play idle animation ONLY if we are standing still and not midjump
		if is_on_floor() and isJumping == false:
			$AnimationPlayer.play("idle")
	
	#calls move_and_slide, we really don't need this function but w.e
	player_movement()
	
	#sees if the player is jumping
	jump()
	dash(direction)

	#sees if the player is sliding down a wall
	wall_slide(delta)
	
	#See comment about jumpCooldown
	jumpCooldown -= delta
	if jumpCooldown <= 0:
		jumpCooldown = 0

#All this does is call move_and_slide, which voodoo magic's the game physics
func player_movement():
	move_and_slide()

#Acceleration function so you don't turn exactly on a dime
func accelerate(direction):
	velocity = velocity.move_toward(speed * direction, acc)

#Little bit of friction so you don't turn on a dime
func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, friction)

#Determine player input
func input() -> Vector2:
	var input_dir = Vector2.ZERO
	
	input_dir.x = Input.get_axis("left", "right")
	input_dir = input_dir.normalized()
	return input_dir

#All jump mechanics handled in this function
func jump():
	
	#Make the character fall due to gravity,
	velocity.y += gravity
	#print("velocity.y:", velocity.y)
	
	if is_on_floor():
		coyoteJumpCounter = 0
		canDoubleJump = true
	
	#If you are trying to jump off the wall
	if is_on_wall() and Input.is_action_pressed("jump") and !is_on_floor():
		canDoubleJump = true
		
		#If hugging the left wall, push off to the right
		if Input.is_action_pressed("left") and jumpCooldown == 0 and whichWallAreYouOn != "left":
			velocity.y = jump_power
			velocity.x = wall_jump_pushback
			#establish that we are on left wall so that we can't jump on left wall to climb upwards
			whichWallAreYouOn = "left"
			
		#if hugging the right wall, push off to the left
		elif Input.is_action_pressed("right") and jumpCooldown == 0 and whichWallAreYouOn != "right":
			velocity.y = jump_power
			velocity.x = -wall_jump_pushback
			#establish that we are on right wall so that we can't jump on left wall to climb upwards
			whichWallAreYouOn = "right"
			
	#Basic Jump from the floor, with coyote jump implementation
	elif Input.is_action_just_pressed("jump") and (is_on_floor() || ((velocity.y >= minCoyoteVelocity) and velocity.y <= maxCoyoteVelocity)) and coyoteJumpCounter == 0:
		
		#if we are coyote jumping
		if !is_on_floor():
			coyoteJumpCounter += 1
		else:
			#if we are doing a legit from the ground jump, reset double jump
			canDoubleJump = true
			
		#the actual jump
		velocity.y = jump_power
		
		#remind engine to reset the wall that the player is on
		whichWallAreYouOn = "none"
		
		#So that the player doesn't immediately bounce off the wall when they faceplant into wall
		jumpCooldown = 0.2
		
		#Play animation, isJumping prevents other animations from clobbering jump animation
		$AnimationPlayer.play("jump")
		isJumping = true
		
	#double jump functionality
	elif Input.is_action_just_pressed("jump") and !is_on_floor() and !is_on_wall() and canDoubleJump:
		velocity.y = jump_power
		$AnimationPlayer.stop()
		$AnimationPlayer.play("jump")
		isJumping = true
		canDoubleJump = false
		print("just double jumped")
		
	#If we aren't actively in the process of jumping, allow other animations to play
	else:
		isJumping = false

#Dash mechanic, at the moment purely for momentum
#Possible damage application once we get further into development?
func dash(direction):
	
	#Just declaring it
	var dashDirection = Vector2.ZERO
	
	#Pull the direction the player is facing from physics loop, dash in that direction
	if direction == -1:
		dashDirection = Vector2(-1,0)
	elif direction == 1:
		dashDirection = Vector2(1,0)
		
	#League of legends has f on flash, I felt inspired to make it the same
	#Actual keybind up for debate
	if Input.is_action_just_pressed("dash") and canDash:
		# could add logic for left or right dash animation
		velocity = dashDirection.normalized()*1000
		#$AnimationPlayer.play("dash")
		canDash = false
		dashing = true
		await get_tree().create_timer(3.0).timeout
		canDash = true
		dashing = false

#Allows player to slowly fall when hanging onto a wall
func wall_slide(delta):
	#If you are on the wall
	if is_on_wall() and !is_on_floor():
		
		#Determine if player can legally wall slide
		if Input.is_action_pressed("left") and whichWallAreYouOn != "left":
			is_wall_sliding = true
		elif Input.is_action_pressed("right") and whichWallAreYouOn != "right":
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false
	
	#Actual wall sliding mechanic
	if is_wall_sliding:
		velocity.y += (wall_slide_gravity * delta)
		velocity.y = min(velocity.y, wall_slide_gravity)
		$AnimationPlayer.play("cling")

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



################
#    HAZARDS   #
################

func _on_kill_zone_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	print("ded") 



################
#    CAMERA    #
################
func _on_room_detector_area_entered(area):
	# get the size of current room
	var collisionShape = area.get_node("CollisionShape2D")
	var size = collisionShape.shape.extents*2
	
	var view_size = get_viewport_rect().size
	if size.y < view_size.y:
		size.y = view_size.y
		
	if size.x < view_size.x:
		size.x = view_size.x
		
	# update the zoom of the camera
	var cam = $Camera2D
	#cam.zoom = Vector2(3.5,3.5)

	cam.limit_top = collisionShape.global_position.y - size.y/2
	cam.limit_left = collisionShape.global_position.x - size.x/2
	cam.limit_bottom = collisionShape.global_position.y + size.y/2
	cam.limit_right = collisionShape.global_position.x + size.x/2
	#cam.zoom = Vector2(3.5,3.5)
	
	print(cam.limit_left)
	print(cam.limit_top)
	print(cam.limit_right)
	print(cam.limit_bottom)
	
	

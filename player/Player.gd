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
	checkQuit()
	did_enemy_attack()
	update_health()
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
			$Sprite2D.flip_h = true
		elif direction == 1:
			$Sprite2D.flip_h = false
		
		#Only play walking animation if we are on the ground and not in midjump
		if is_on_floor() and isJumping == false:
			$AnimationPlayer.play("walk")
		
	#If we're not inputting left or right movement
	else:
		add_friction()
		
		#Play idle animation ONLY if we are standing still and not midjump
		if is_on_floor() and isJumping == false:
			$AnimationPlayer.play("idle")
	
	if Input.is_action_just_pressed("attack") and !Global.player_current_attack:
		if direction == 1:
			$AttackPlayer.play("slash")
		else:
			$AttackPlayer.play("slashleft")
		Global.player_current_attack = true
		$AttackCD.start()
	
	if Input.is_action_just_pressed("interact") and nearInteract: # change this as its funky right now
		Global.interact = all_interactions[0].interact_label
		print(Global.interact)
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
	
	death()

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
		#canDoubleJump = true
		
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
	elif Input.is_action_just_pressed("jump") and canDoubleJump and (is_on_floor() || ((velocity.y >= minCoyoteVelocity) and velocity.y <= maxCoyoteVelocity)) and coyoteJumpCounter == 0:
		
		#if we are coyote jumping
		if !is_on_floor():
			coyoteJumpCounter += 1
			canDoubleJump = false
		#else:
			##if we are doing a legit from the ground jump, reset double jump
			#canDoubleJump = true
			
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
var nearInteract = false
func _on_interaction_area_area_entered(area):
	nearInteract = true
	#if Input.is_action_just_pressed("interact"): # change this as its funky right now
	all_interactions.insert(0,area) # store an interaction
	updateInteractions()


func _on_interaction_area_area_exited(area):
	nearInteract = false
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
	print("ouch, health is ", health)
	health -= 1
	$Sprite2D.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	$Sprite2D.modulate = Color.WHITE




################
#    CAMERA    #
################
# the below function is buggy so imma leave it be for now since i think the camera needs a whole rework
func _on_room_detector_area_entered(area):
	# get the size of current room
	var collisionShape = area.get_node("CollisionShape2D")
	var size = collisionShape.shape.size*2
	print(size)
	print(collisionShape.position)
	
	#var view_size = get_viewport_rect().size
	#if size.y < view_size.y:
		#size.y = view_size.y
		#
	#if size.x < view_size.x:
		#size.x = view_size.x
		
	# update the zoom of the camera
	var cam = $Camera2D
	
	print(size.x)
	print(size.y)
	#
	#cam.limit_top = collisionShape.global_position.y - size.y/2
	#cam.limit_left = collisionShape.global_position.x - size.x/2
	#cam.limit_right = cam.limit_left + size.x
	#cam.limit_bottom = cam.limit_top + size.y
	#cam.global_position = collisionShape.global_position
	
	#print(cam.limit_left)
	#print(cam.limit_top)
	#print(cam.limit_right)
	#print(cam.limit_bottom)




################
#    COMBAT    #
################
# combat vars
var enemy_inattack_range = false
var enemy_attack_cooldown = true
var MAX_HEALTH = 10
var health = MAX_HEALTH
var player_alive = true

func update_health():
	var healthbar = $HealthBar
	healthbar.value = health
	if health >= MAX_HEALTH:
		healthbar.visible = false
	else:
		healthbar.visible = true
#func _on_slash_area_area_entered(area):
	#print("in range")
	#enemy = area
	#enemy_inattack_range = true
#
#func _on_slash_area_area_exited(area):
	#enemy = null
	#enemy_inattack_range = false

#func _on_slash_area_body_entered(body):
	#if body.has_method("drone"):
		#print("in range")
		#enemy_inattack_range = true
#
##
#func _on_slash_area_body_exited(body):
	#if body.has_method("drone"):
		#enemy_inattack_range = false

# is a body in the hitbox that has a function enemy in the script?
func _on_temp_hitbox_body_entered(body):
	if body.has_method("enemy"):
		print("in range")
		enemy_inattack_range = true


func _on_temp_hitbox_body_exited(body):
	if body.has_method("enemy"):
		print("not in range")
		enemy_inattack_range = false


func did_enemy_attack():
	await get_tree().create_timer(3.0).timeout # two second grace period before attack
	if enemy_inattack_range and enemy_attack_cooldown:
		health -= 1
		
		print(health)
		enemy_attack_cooldown = false
		$DamageCD.start()
		
		$Sprite2D.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		$Sprite2D.modulate = Color.WHITE
		#$RegenCD.start()

func _on_damage_cd_timeout():
	$DamageCD.stop()
	enemy_attack_cooldown = true # Replace with function body.

func _on_attack_cd_timeout():
	$AttackCD.stop()
	Global.player_current_attack = false # this references a variable in "global.gd", it is autoloaded as global under project settings

func death():
	if health <= 0:
		player_alive = false
		print("ded")
		#disable input?
		$Death.visible = true
		#$DeathSound.play()
		# eventually make this a quit/respawn screen
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://Menu.tscn")
		# death screen
		

# needed for the "has_method" strat
func player():
	pass

func checkQuit():
	if Input.is_action_just_pressed("quit"):
		await get_tree().create_timer(0.5).timeout # this is needed to prevent a bug with other timers
		get_tree().change_scene_to_file("res://Menu.tscn") # current quit is just to go back to main menu

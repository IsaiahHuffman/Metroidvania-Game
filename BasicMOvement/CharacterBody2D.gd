extends CharacterBody2D


const speed = 550.0
const jump_power = -2000.0

const acc = 50
const friction = 70

const gravity = 120

const wall_jump_pushback = 100

const wall_slide_gravity = 100
var is_wall_sliding = false

func _physics_process(delta):
	var input_dir: Vector2 = input()
	
	if input_dir != Vector2.ZERO:
		accelerate(input_dir)
	else:
		add_friction()
	player_movement()
	jump()
	wall_slide(delta)

func player_movement():
	move_and_slide()

func accelerate(direction):
	velocity = velocity.move_toward(speed * direction, acc)
func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, friction)

func input() -> Vector2:
	var input_dir = Vector2.ZERO
	
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir = input_dir.normalized()
	print(input_dir)
	return input_dir
	
func jump():
	velocity.y += gravity
	if Input.is_action_just_pressed("ui_select"):
		if is_on_floor():
			velocity.y = jump_power
		if is_on_wall() and Input.is_action_pressed("ui_right"):
			velocity.y = jump_power
			velocity.x = -wall_jump_pushback
		if is_on_wall() and Input.is_action_pressed("ui_left"):
			velocity.y = jump_power
			velocity.x = wall_jump_pushback

func wall_slide(delta):
	if is_on_wall() and !is_on_floor():
		if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
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



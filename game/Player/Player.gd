extends CharacterBody2D

# Physics
const SPEED = 200.0
const JUMP_VELOCITY = -450.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var platform_velocity = Vector2.ZERO

# Double Jump
var jump_count = 0
var max_jumps = 1

# Coyote Timer
@onready var coyote_timer = $CoyoteJump

# Attacking
var attacking = false
var enemy_in_range = false

# Shooting
@onready var bulletPath = preload("res://game/Player/Bullet.tscn")
var shooting = false
var bullet_direction

# Death
var dead = false

# Dashing
var dashing = false
var dash_speed = 1000
var dash_duration = 0.2
var can_dash = true
@onready var dash_timer = $DashTimer
@onready var can_dash_timer = $DashAgainTimer      #1 sec CD


func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Stuff for moving
	movement()
	
	# Stuff for jumping
	jump()
	
	if global_position.y > 985:
		death()
	
	# Stuff for dashing
	if Input.is_action_just_pressed("ui_dash") and can_dash:
		dashing = true
		can_dash = false
		dash_timer.start()
		can_dash_timer.start()
	
	# Stuff for attacking
	if Input.is_action_pressed("ui_right"):
		get_node("AttackArea").set_scale(Vector2(1, 1))
		$ShootArea.scale.x = 1
	elif Input.is_action_pressed("ui_left"): 
		get_node("AttackArea").set_scale(Vector2(-1, 1))
		$ShootArea.scale.x = -1
	if Input.is_action_pressed("ui_attack") and attacking == false:
		attack()
	else:
		attacking = false
	
	# Stuff for shooting
	if Input.is_action_just_pressed("ui_shoot"):
		shoot()
	else:
		shooting = false
	
	# Coyote Timer - Checks if player is leaving ledge and about to jump
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_timer.start()
	
func movement():
	# Get direction of user input.
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Move based on direction (value 1 for right, -1 for left)
	if direction:
		if dashing:
			var dash_direction = Vector2.ZERO
			if Input.is_action_pressed("ui_right"):
				dash_direction.x += 1
			if Input.is_action_pressed("ui_left"):
				dash_direction.x -= 1
			velocity = dash_direction.normalized() * dash_speed
		else:
			velocity.x = direction * SPEED
	else: # Idle
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Fall down one way platforms
	if Input.is_action_pressed("ui_down") and is_on_floor():
		position.y += 1


func jump():
	# Handle jump.
	if Input.is_action_just_pressed("ui_select") and jump_count < max_jumps:
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	#Reset jump count after falling down
	if is_on_floor() or coyote_timer.time_left > 0.0:
		jump_count = 0
	

func attack():
		
	attacking = true
	
	if enemy_in_range == true and attacking == true:
		var hit_list = $AttackArea.get_overlapping_areas()
		for area in hit_list:
			var parent = area.get_parent()
			parent.queue_free()

func shoot():
	shooting = true
	var bullet = bulletPath.instantiate()
	
	bullet.position = $ShootArea/Shoot.global_position 
	bullet.velocity_placeholder = $ShootArea.scale.x
	get_parent().add_child(bullet)
		
	

func _on_attack_area_body_entered(body):
	# If a body enters player attack range
	if body and body.name != "TileMap" and body.name != "Player":
		enemy_in_range = true
		
		
func _on_attack_area_body_exited(body):
	# If a body exits player attack range
	if body and body.name != "TileMap" and body.name != "Player":
		enemy_in_range = false
		
func death():
	if not dead:
		dead = true
		velocity = Vector2.ZERO
		print("dead")
		get_tree().reload_current_scene()


# Make it stop dashing
func _on_dash_timer_timeout():
	dashing = false

# Allow dash again
func _on_dash_again_timer_timeout():
	can_dash = true

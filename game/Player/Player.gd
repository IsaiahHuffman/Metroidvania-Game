extends CharacterBody2D

# Physics
const SPEED = 200.0
const JUMP_VELOCITY = -300.0 # was -450
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var platform_velocity = Vector2.ZERO
const wall_slide_gravity = 100

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
var dash_speed = 850
var dash_duration = 0.2
var can_dash = true
@onready var dash_timer = $DashTimer
@onready var can_dash_timer = $DashAgainTimer      #1 sec CD

# clinging, not implemented
var hasClung = false

func _physics_process(delta):
	checkQuit()
	did_enemy_attack()
	update_health()
	
	if velocity.x != 0:
		$RegenTimer.stop()
		$RegenTimer.start()
	if !enemy_attack_cooldown:
		$RegenTimer.stop()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	# this was the cling logic but its super buggy so imma just let it rest here
	#elif not is_on_floor() and is_on_wall():
		#if Input.is_action_pressed("right") and hasClung == false:
			##velocity.y += (wall_slide_gravity * delta)
			##velocity.y = min(velocity.y, wall_slide_gravity)
			##hasClung = true
			#velocity.y = 20
		#elif Input.is_action_pressed("left") and hasClung == false:
			#velocity.y += (wall_slide_gravity * delta)
			#velocity.y = min(velocity.y, wall_slide_gravity)
			#hasClung = true
		#else:
			#velocity.y += gravity * delta
	#
	#if is_on_floor():
		#hasClung = false
	
	
	movement() # function that handles moving
	jump() # function that handles moving
	
	#if global_position.y > 985: # handles falling into the void, this should be changed on the new map
		#death()
	if Input.is_action_just_pressed("interact") and nearInteract: # change this as its funky right now
		Global.interact = all_interactions[0].interact_label
		print(Global.interact)
	
	# Stuff for dashing
	if Input.is_action_just_pressed("dash") and can_dash:
		dashing = true
		can_dash = false
		dash_timer.start()
		can_dash_timer.start()
	
	# Stuff for changing attack direction
	if Input.is_action_pressed("right"):
		get_node("AttackArea").set_scale(Vector2(1, 1))
		$ShootArea.scale.x = 1
	elif Input.is_action_pressed("left"): 
		get_node("AttackArea").set_scale(Vector2(-1, 1))
		$ShootArea.scale.x = -1
	if Input.is_action_pressed("attack") and Global.player_current_attack == false:
		attack()
		$MovementPlayer.stop()
		#$MovementPlayer.play("swing")
		Global.player_current_attack = true
		$SlashCD.start()
		$AttackPlayer.play("slash")
	else:
		attacking = false
	
	# Stuff for shooting
	if Input.is_action_just_pressed("shoot"):
		if shooting == false:
			$ShootCD.stop()
			shoot()
	#else:
		#shooting = false
	
	# Coyote Timer - Checks if player is leaving ledge and about to jump
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_timer.start()
	
	checkDeath()



######## START OF MOVEMENT CODE ########
func movement():
	# Get direction of user input.
	var direction = Input.get_axis("left", "right")
	
	# Move based on direction (value 1 for right, -1 for left)
	if direction:
		if dashing:
			var dash_direction = Vector2.ZERO
			if Input.is_action_pressed("right"):
				dash_direction.x += 1
			if Input.is_action_pressed("left"):
				dash_direction.x -= 1
			velocity = dash_direction.normalized() * dash_speed
			$MovementPlayer.play("dash")
		else:
			if Input.is_action_pressed("left"):
				$Sprite2D.flip_h = true
				$SlashSprite.set_scale(Vector2(1.5, -1.5))
				$SlashSprite.position.x = -22
			else:
				$Sprite2D.flip_h = false
				$SlashSprite.set_scale(Vector2(1.5, 1.5)) # flip proper way
				$SlashSprite.position.x = 22 # adjust position
				
				
			
			velocity.x = direction * SPEED
			if is_on_floor():
				$MovementPlayer.play("walk")
	else: # Idle
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			$MovementPlayer.play("idle")
	
	# Fall down one way platforms
	if Input.is_action_pressed("down") and is_on_floor():
		$MovementPlayer.play("fall")		
		position.y += 1

func jump():
	# Handle jump.
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		$MovementPlayer.stop()
		$MovementPlayer.play("jump")
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	#Reset jump count after falling down
	if is_on_floor() or coyote_timer.time_left > 0.0:
		jump_count = 0

# Make it stop dashing
func _on_dash_timer_timeout():
	dashing = false

# Allow dash again
func _on_dash_again_timer_timeout():
	can_dash = true

######## END OF MOVEMENT CODE ########

######## START OF INTERACTIONS CODE ########

@onready var all_interactions = [] # store interactions in an array
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
		#$"Interactions/InteractLabel".text = all_interactions[0].interact_label
		print(all_interactions[0].interact_label)
	#else:
		#$"Interactions/InteractLabel".text = ""
######## END OF INTERACTIONS CODE ########

#func death():
	#if not dead:
		#dead = true
		#velocity = Vector2.ZERO
		#print("dead")
		#get_tree().reload_current_scene()


################
#    HAZARDS   #
################
func _on_kill_zone_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	print("ouchies")
	#print("ouch, health is ", health)
	health -= 1
	$Sprite2D.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	$Sprite2D.modulate = Color.WHITE



func checkQuit():
	if Input.is_action_just_pressed("pause"):
		await get_tree().create_timer(0.5).timeout # this is needed to prevent a bug with other timers
		get_tree().change_scene_to_file("res://game/Menu.tscn") # current quit is just to go back to main menu





################
#    COMBAT    #
################
# combat vars
var enemy_inattack_range = false
var enemy_attack_cooldown = true
var MAX_HEALTH = 15
var health = MAX_HEALTH
var player_alive = true

func update_health():
	var healthbar = $HealthBar
	healthbar.value = health
	if health >= MAX_HEALTH:
		healthbar.visible = false
	else:
		healthbar.visible = true


# detect if enemy is close enough for slashing
func _on_attack_area_body_entered(body): # slash attack range
	if body.is_in_group("Enemy"):
		print("in range ", body)
		enemy_inattack_range = true

# detect if enemy is far from slashing
func _on_attack_area_body_exited(body): # slash attack range
	print("bye")
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

func _on_slash_cd_timeout():
	$SlashCD.stop()
	Global.player_current_attack = false # this references a variable in "global.gd", it is autoloaded as global under project settings

func checkDeath():
	if health <= 0:
		player_alive = false
		print("ded")
		#disable input?
		$Death.visible = true
		#$DeathSound.play()
		# eventually make this a quit/respawn screen
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://Game/Menu.tscn")
		# death screen

func take_damage(damage):
	health-=damage
	update_health()


######## START OF ATTACKING CODE ########
func attack():
	attacking = true
	Global.player_current_attack = true
	
	if enemy_in_range == true and Global.player_current_attack == true:
		var hit_list = $AttackArea.get_overlapping_areas()
		for area in hit_list:
			var parent = area.get_parent()
			parent.queue_free()


func shoot():
	$ShootCD.start()
	shooting = true
	var bullet = bulletPath.instantiate()
	#bullet.position = $ShootArea/Shoot.global_position # this was causing bullets to only spawn in one location
	#var spawn = position
	bullet.position = position # changed bullet logic to spawn on the player
	bullet.velocity_placeholder = $ShootArea.scale.x
	get_parent().add_child(bullet)
	

func _on_shoot_cd_timeout():
	shooting = false
######## END OF ATTACKING CODE ########

var regen = false
func _on_regen_timer_timeout():
	regen = false
	health += 5

extends CharacterBody2D


var speed = 50.0
const JUMP_VELOCITY = -400.0

# Enemy AI variables
var player_chase = false
var chase_speed = 80
var direction = Vector2.RIGHT

var player

# Living Vars
const MAX_HEALTH = 8
var health = MAX_HEALTH
var player_attack_zone = false
var can_take_damage =  true
var is_alive = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	deal_with_damage()
	update_health()
	# Add the gravity.
	if not is_on_floor():
		$AnimationPlayer.play("fall")
		velocity.y += gravity * delta
	if is_alive:
		$AnimationPlayer.play("walk")
	# If player enters detection zone	
	if player_chase and is_alive:
		chase_player()
	elif is_alive: # Idle AI
		idle_ai()
	
	if direction.x < 0:
		$Sprite2D.flip_h = false
	else:
		$Sprite2D.flip_h = true
	move_and_slide()

func _on_player_detection_body_entered(body):
	if body.name == "Player":
		player = body		#The entity that just entered the detection range is the body (our player)
		player_chase = true

func _on_player_detection_body_exited(body):
	if body.name == "Player":
		player = null
		player_chase = false

func chase_player():
	#$Sprite2D.modulate = Color(1, 0, 0)		#Red for angry
	direction = (player.global_position - self.global_position).normalized()
	velocity.x = direction.x * chase_speed


func idle_ai():
	#$Sprite2D.modulate = Color(0, 1, 0)		#Green 
		
	if is_on_wall():		#If touched wall, change direction
		direction.x *= -1	
		velocity.x = speed * direction.x  # Update velocity with new direction
	if !$"Edge Detection/RayCast_R".is_colliding() or !$"Edge Detection/RayCast_L".is_colliding():	#If touched ledge of a cliff
		direction.x *= -1
		velocity.x = speed * direction.x 

	velocity.x = speed * direction.x 




# This is used to update the health bar of enemy
func update_health():
	var healthbar = $HealthBar
	healthbar.value = health
	if health >= MAX_HEALTH:
		healthbar.visible = false
	else:
		healthbar.visible = true

# death is among us
func die():
	is_alive = false
	player_inattack_range = false
	Global.snailCount += 1
	#$AnimationPlayer.stop()
	$AnimationPlayer.play("death")
	await get_tree().create_timer(0.6).timeout # two second grace period before attack
	self.queue_free()


var player_inattack_range = false
func _on_hitbox_body_entered(body):
	if body.name == "Player":
		print("the player is a little close")
		player_inattack_range = true


func _on_hitbox_body_exited(body):
	if body.name == "Player":
		print("the player can no longer hurt me")
		player_inattack_range = false


func deal_with_damage():
	if (Global.player_current_attack and player_inattack_range and is_alive  == true):
		if can_take_damage == true:
			health -= 1
			$DamageCD.start()
			can_take_damage = false
			#$Sprite2D.modulate = Color.RED
			#await get_tree().create_timer(0.1).timeout
			#$Sprite2D.modulate = Color.WHITE
			print("snail health = ", health)
	if health <= 0:
		#player_chase = false
		die()


func _on_damage_cd_timeout():
	$DamageCD.stop()
	can_take_damage = true

func take_damage(damage):
	health-=damage
	update_health()
	deal_with_damage()


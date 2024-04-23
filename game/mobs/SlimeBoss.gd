extends CharacterBody2D


const speed = 150.0
const JUMP_VELOCITY = -500.0
var direction = Vector2.RIGHT

# Randomly jump
var can_jump = true
var jumping = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	deal_with_damage()
	update_health()
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	#idle_ai()
	if is_on_wall():		#If touched wall, change direction
		direction.x *= -1	
		velocity.x = direction.x * speed
	if is_on_floor():
		velocity.x = 0
	# Jump 
	if can_jump:
		can_jump = false
		$AnimationPlayer.play("jump")
		velocity.y = JUMP_VELOCITY
		velocity.x = direction.x * speed
		print("jump")
		jumping = true
		$JumpTimer.start()

	move_and_slide()
	
func idle_ai():
	$Sprite2D.modulate = Color(1, 1, 0)		#Green 
		
	if is_on_wall():		#If touched wall, change direction
		direction.x *= -1	
		velocity.x = speed * direction.x  # Update velocity with new direction
	velocity.x = speed * direction.x 


func _on_jump_timer_timeout():
	can_jump = true


const MAX_HEALTH = 15
var health = MAX_HEALTH
var player_attack_zone = false
var can_take_damage =  true
var is_alive = true


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
	Global.slimeCount += 1
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
			print("drone health = ", health)
	if health <= 0:
		die()

func take_damage(damage):
	health-=damage
	update_health()
	deal_with_damage()

func _on_damage_cd_timeout():
	$DamageCD.stop()
	can_take_damage = true

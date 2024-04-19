extends CharacterBody2D

var speed = 30 # this is not speed in this context but rather a mutliplier of sorts
var player_chase = false
var player = null
const MAX_HEALTH = 4
var health = MAX_HEALTH
var player_attack_zone = false
var can_take_damage =  true
var is_alive = true
var knockback_dir
var dir = 1
var knockback = false

func _physics_process(delta):
	$AnimationPlayer.play("active")
	deal_with_damage()
	update_health()
	if is_alive:
		if player_chase:
			var direction = global_position.direction_to((player.global_position))
			velocity = direction*speed
			
			if(player.global_position.x > global_position.x):
				$Sprite2D.flip_h = true
				#dir = -1
			else:
				$Sprite2D.flip_h = false
				#dir = 1
		else:
			velocity = Vector2(0,0)
		if knockback == true:
			print("KNOCKBACK SUCCESSFULL")
			knockback = false
	move_and_slide()


# player is in the detection area of a drone
func _on_detection_area_body_entered(body):
	print("player found")
	player = body
	player_chase = true


func _on_detection_area_body_exited(body):
	print("player lost")
	player = null
	player_chase = false


# update health and such accordingly

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
	$AnimationPlayer.stop()
	$AnimationPlayer.play("death")
	await get_tree().create_timer(0.5).timeout # two second grace period before attack
	self.queue_free()


func enemy():
	pass



var player_inattack_range = false
func _on_hitbox_body_entered(body):
	if body.has_method("player"):
		print("the player is a little close")
		player_inattack_range = true


func _on_hitbox_body_exited(body):
	if body.has_method("player"):
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
				player_chase = false
				die()



func _on_damage_cd_timeout():
	$DamageCD.stop()
	can_take_damage = true

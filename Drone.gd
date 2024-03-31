extends CharacterBody2D

var speed = 300 # this is not speed in this context but rather a mutliplier of sorts
var player_chase = false
var player = null
var health = 100
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
			#position += (player.position - position)/speed
			#print("enemy")
			#print(position)
			#print("you")
			#print(player.position)
			
			var direction = global_position.direction_to((player.global_position))
			velocity = direction*10
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



# getting attacked?
func _on_attack_area_body_entered(body):
	if body.has_method("player"):
		player_attack_zone = true

# no more getting attacked!
func _on_attack_area_body_exited(body):
	if body.has_method("player"):
		player_attack_zone = false	


# update health and such accordingly
func deal_with_damage():
	#if (Global.player_current_attack and player_attack_zone and is_alive  == true):
		#if can_take_damage == true:
			#health = health - 5
			#$take_damge.start()
			#can_take_damage = false
			#print("Slime health = ", health)
			#if health <= 0:
				#player_chase = false
				#die()
				pass

# This is used to update the health bar of enemy
func update_health():
	var healthbar = $HealthBar
	healthbar.value = health
	if health >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true

# death is among us
func die():
	is_alive = false
	$AnimationPlayer.play("death")
	$death_timer.start()






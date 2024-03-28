extends CharacterBody2D

var speed = 30
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
	deal_with_damage()
	update_health()	
	if is_alive:
		if player_chase:
			position+= (player.position - position) / speed
			$AnimatedSprite2D.play("walk")
			if(player.position.x - position.x < 0):
				$AnimatedSprite2D.flip_h = true
				dir = -1
			else:
				$AnimatedSprite2D.flip_h = false
				dir = 1
		else:
			$AnimatedSprite2D.play("idle")
		if knockback == true:
			print("KNOCKBACK SUCCESSFULL")
			knockback = false

func enemyslime():
	pass

func _on_attack_area_body_entered(body):
	if body.has_method("myplayer"):
		player_attack_zone = true


func _on_attack_area_body_exited(body):
	if body.has_method("myplayer"):
		player_attack_zone = false	
func _on_detection_area_body_entered(body):
	player = body
	player_chase = true
	


func _on_detection_area_body_exited(body):
	player = null
	player_chase = false

func update_health():
	var healthbar = $enemy_healthbar
	healthbar.value = health
	if health >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true
func die():
	is_alive = false
	$AnimatedSprite2D.play("death_a")
	$death_timer.start()
	
	
		
func deal_with_damage():
	if (Global.player_current_attack and player_attack_zone and is_alive  == true):
		if can_take_damage == true:
			health = health - 5
			$take_damge.start()
			can_take_damage = false
			print("Slime health = ", health)
			if health <= 0:
				player_chase = false
				die()
		










func _on_area_2d_body_entered(body):
	if body.has_method("myplayer"):
		player_attack_zone = true
	



func _on_area_2d_body_exited(body):
	if body.has_method("myplayer"):
		player_attack_zone = false



func _on_take_damge_timeout():
	can_take_damage = true



func _on_death_timer_timeout():
	print("ENEMY KILLED")
	self.queue_free()


func _on_hero_knockback():
	var player_dir = get_parent().get_node("hero").dir
	knockback_dir = player_dir 
	dir = knockback_dir 
	var knockback_strength = 50 # Adjust based on your game's needs
	var knockback_strength_y = -10
	position += Vector2(knockback_strength * knockback_dir, knockback_strength_y)
	knockback = true
	

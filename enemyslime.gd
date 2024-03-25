extends CharacterBody2D
@export var speed: int = 100
var enemy_in_range = false
var enemy_attack_cool_down = true
var health = 100
var alive = true
func _physics_process(delta):
	player_movement(delta)
	enemy_attack()
func player_movement(delta):
	
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		velocity.y = speed
		velocity.x = 0 
	elif Input.is_action_pressed("ui_up"):
		velocity.y = -speed
		velocity.x = 0
	else:
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide()
	
	
func hero():
	pass
func myplayer():
	pass
func _on_player_hitbox_body_entered(body):
	if body.has_method("enemyslime"):
		enemy_in_range = true
	


func _on_player_hitbox_body_exited(body):
	if body.has_method("enemyslime"):
		enemy_in_range = false
func enemy_attack():
	if enemy_in_range:
		print("player took damage!")	 

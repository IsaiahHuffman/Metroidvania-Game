extends CharacterBody2D
@export var speed: int = 100
var current_dir = "none"
var enemy_in_range = false
var enemy_attack_cool_down = true
var health = 100
var alive = true
var attack_inprogress = false

func myplayer():
	pass
	
func _ready():
	$AnimatedSprite2D.play("idle")
	
func _physics_process(delta):
	player_movement(delta)
	enemy_attack()
	close_attack()
	update_health()
	if health <= 0:
		alive = false
		health = 0
		print("player is killed")
		self.queue_free()
func player_movement(delta):
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
		velocity.y = speed
		velocity.x = 0 
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
		velocity.y = -speed
		velocity.x = 0
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide()
	
func play_anim(movement):
		var dir = current_dir
		var animation = $AnimatedSprite2D
		if  dir == "right":
			animation.flip_h = false
			if movement == 1:
				animation.play("walk")
			elif movement == 0:
				if attack_inprogress == false:
					animation.play("idle")
		if  dir == "left":
			animation.flip_h = true
			if movement == 1:
				animation.play("walk")
			elif movement == 0:
				if attack_inprogress == false:
					animation.play("idle")


func _on_player_hitbox_body_entered(body):
	if body.has_method("enemyslime"):
		enemy_in_range = true
	


func _on_player_hitbox_body_exited(body):
	if body.has_method("enemyslime"):
		enemy_in_range = false

func enemy_attack():
	if enemy_in_range and enemy_attack_cool_down == true:
		health = health - 5
		enemy_attack_cool_down = false
		$Timer.start()
		print(health)	 



func _on_timer_timeout():
	enemy_attack_cool_down = true

func close_attack():
	var dir = current_dir
	if Input.is_action_just_pressed("attack"):
		Global.player_current_attack = true
		attack_inprogress = true
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("attack")
			$attack_timer.start()
		if dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("attack")
			$attack_timer.start()




func _on_attack_timer_timeout():
	$attack_timer.stop()
	Global.player_current_attack =false
	attack_inprogress = false

func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	if health >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true




func _on_healthgen_timeout():
	
	if health < 100 or health > 0:
		$healthgen.start()
		health = health +20
		if health >= 100:
			health = 100
		

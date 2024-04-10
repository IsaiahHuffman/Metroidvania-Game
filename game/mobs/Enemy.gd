extends CharacterBody2D


var speed = 50.0
const JUMP_VELOCITY = -400.0

# Enemy AI variables
var chase = false
var chase_speed = 150
var direction = Vector2.RIGHT

var player

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# If player enters detection zone	
	if chase:
		chase_player()
	else: # Idle AI
		idle_ai()
		
	move_and_slide()

func _on_player_detection_body_entered(body):
	if body.name == "Player":
		chase = true
		player = body		#The entity that just entered the detection range is the body (our player)

func _on_player_detection_body_exited(body):
	if body.name == "Player":
		chase = false
		
func chase_player():
	$Sprite2D.modulate = Color(1, 0, 0)		#Red for angry
	direction = (player.global_position - self.global_position).normalized()
	velocity.x = direction.x * chase_speed

func idle_ai():
	$Sprite2D.modulate = Color(0, 1, 0)		#Green 
		
	if is_on_wall():		#If touched wall, change direction
		direction.x *= -1	
		velocity.x = speed * direction.x  # Update velocity with new direction
	if !$"Edge Detection/RayCast_R".is_colliding() or !$"Edge Detection/RayCast_L".is_colliding():	#If touched ledge of a cliff
		direction.x *= -1  
		velocity.x = speed * direction.x 
	velocity.x = speed * direction.x 
	


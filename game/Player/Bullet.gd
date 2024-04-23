extends CharacterBody2D

var speed = 300
var velocity_placeholder : float

func _physics_process(delta):
	move_local_x(velocity_placeholder * speed * delta)

		
func _on_hit_detector_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage(2)
		self.queue_free()
		#body.queue_free()
	
	if body and body.name == "TileMap":
		self.queue_free()
	


func _on_flight_timer_timeout(): # reduce range of bullet by giving it a lifespan
	self.queue_free()

func bullet():
	pass

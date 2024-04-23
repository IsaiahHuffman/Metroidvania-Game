extends StaticBody2D

var time = 1
var initial_position 

func _ready():
	set_process(false)
	initial_position = $CollisionShape2D/Sprite2D.position
	
func _process(_delta):
	time += 1
	$CollisionShape2D/Sprite2D.position = initial_position + Vector2(0, sin(time)*1.5)
	
func _on_player_detection_body_entered(body):
	if visible:
		set_process(true)
		$DeleteTimer.start(1)
		$AnimationPlayer.play("break")

func _on_delete_timer_timeout():
	$CollisionShape2D.disabled = true
	visible = false
	time = 1
	$ReappearTimer.start(4)

func _on_reappear_timer_timeout():
	if not visible:
		$AnimationPlayer.stop()
		$CollisionShape2D.disabled = false
		visible = true
		set_process(false)

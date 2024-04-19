extends Node2D




func _on_audio_stream_player_finished():
	$MainMusic.play()
	pass

func _physics_process(delta):
	if Global.interact == "door":
		$Door/CollisionShape2D.set_disabled(true)
		$Door/door.set_visible(false)		
		print("door opened")
		Global.interact = "none"
		#move_and_slide()
	

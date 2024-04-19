extends Node2D




func _on_audio_stream_player_finished():
	$MainMusic.play()
	pass

func _physics_process(delta):
	if Global.interact == "door1":
		$Doors/Door1/CollisionShape2D.set_disabled(true)
		$Doors/Door1/door.set_visible(false)
		$Doors/door1/Sprite2D.frame = 1
		print(Global.interact," opened")
		Global.interact = "none"
		#move_and_slide()
	if Global.interact == "door2":
		$Doors/Door2/CollisionShape2D.set_disabled(true)
		$Doors/Door2/door.set_visible(false)
		$Doors/door2/Sprite2D.frame = 1
		print(Global.interact," opened")
		Global.interact = "none"
	if Global.interact == "door3":
		$Doors/Door3/CollisionShape2D.set_disabled(true)
		$Doors/Door3/door.set_visible(false)
		$Doors/door3/Sprite2D.frame = 1
		print(Global.interact," opened")
		Global.interact = "none"
	if Global.interact == "door4":
		$Doors/Door4/CollisionShape2D.set_disabled(true)
		$Doors/Door4/door.set_visible(false)
		$Doors/door4/Sprite2D.frame = 1
		print(Global.interact," opened")
		Global.interact = "none"
	if Global.interact == "door5":
		$Doors/Door5/CollisionShape2D.set_disabled(true)
		$Doors/Door5/door.set_visible(false)
		$Doors/door5/Sprite2D.frame = 1
		print(Global.interact," opened")
		Global.interact = "none"

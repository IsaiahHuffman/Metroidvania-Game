extends Node2D


var goodEnding = "Although you awoke in a strange cave with no idea who you are or why you are here, 
you took it upon yourself to aid the cave to cleanse it of all the evils within. 
The Cave thanks you. Now, it is no longer suffering, all thanks to your adventurous spirit
It has been ages since the Cave has been free of harm. Fantastic job young one."

var neutralEnding = "When you awoke, you knew there was something meant for you to accomplish in this unfamiliar yet
inviting cave. you cleanse more than you needed to, for that the Cave is thankful. Its pain is 
reduced because of your curious spirit. Good job young one."

var badEnding = "Although there were many things you could have done here, you did all you needed for you to escape.
The Cave hopes you enjoy your newfound freedom and hopes that you will come back very soon to help
what kept you safe. One day you will learn young one."

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
		Global.buttonCount+=1
		
		#move_and_slide()
	if Global.interact == "door2":
		$Doors/Door2/CollisionShape2D.set_disabled(true)
		$Doors/Door2/door.set_visible(false)
		$Doors/door2/Sprite2D.frame = 1
		print(Global.interact," opened")
		Global.interact = "none"
		Global.buttonCount+=1
		
	if Global.interact == "door3":
		$Doors/Door3/CollisionShape2D.set_disabled(true)
		$Doors/Door3/door.set_visible(false)
		$Doors/door3/Sprite2D.frame = 1
		print(Global.interact," opened")
		Global.interact = "none"
		Global.buttonCount+=1
		
	if Global.interact == "door4":
		$Doors/Door4/CollisionShape2D.set_disabled(true)
		$Doors/Door4/door.set_visible(false)
		$Doors/door4/Sprite2D.frame = 1
		print(Global.interact," opened")
		Global.interact = "none"
		Global.buttonCount+=1
		
	if Global.interact == "door5":
		$Doors/Door5/CollisionShape2D.set_disabled(true)
		$Doors/Door5/door.set_visible(false)
		$Doors/door5/Sprite2D.frame = 1
		print(Global.interact," opened")
		Global.interact = "none"
		Global.buttonCount+=1
	if Global.interact == "end":
		$Doors/end/Sprite2D.frame = 1
		print(Global.interact," opened")
		Global.interact = "none"
		Global.snailCount = 0
		Global.droneCount = 0
		Global.slimeCount = 0
		Global.buttonCount = 0
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://game/Menu.tscn")
	# add logic to check the status of both bosses
	# once you go into a certain room after defeating the 2 bosses then you press a button and it ends the game
	# , then show a menu that congratulates the player, both with completing the game and kill counts along with button counts
	# if a player defeated all enemies and pressed all button be very happy with that person
	if Global.slimeCount >= 2:
		$Doors/Door6/CollisionShape2D.set_disabled(true)
		$Doors/Door6/door.set_visible(false)
		$Labels/ExitLabel.set_visible(false)
	
	if Global.interact == "exit":
		$Player.position = $Doors/exit.position
		print(Global.interact," opened")
		Global.interact = "none"
		if Global.slimeCount >= 2 and Global.droneCount >= 20 and Global.snailCount >= 25 and Global.buttonCount >= 5:
			$Labels/Ending.text = goodEnding
		elif Global.slimeCount >= 2 and Global.droneCount >= 12 and Global.snailCount >= 12 and Global.buttonCount >= 3:
			$Labels/Ending.text = neutralEnding
		else:
			$Labels/Ending.text = badEnding
		await get_tree().create_timer(2.0).timeout
		for i in $Labels/Ending.get_parsed_text():
			$Labels/Ending.visible_characters += 1
			await get_tree().create_timer(0.075).timeout

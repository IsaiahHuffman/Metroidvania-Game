extends Control





func _on_options_pressed():
	#$Click.play()
	get_tree().change_scene_to_file("res://game/Menu.tscn")

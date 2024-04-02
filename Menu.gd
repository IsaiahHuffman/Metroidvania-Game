extends Control



func _on_play_pressed():
	$Click.play()
	get_tree().create_timer(0.75) # this can be removed, i just felt this made the menu feel better
	get_tree().change_scene_to_file("res://game/Map.tscn")



func _on_quit_pressed():
	$Click.play()
	get_tree().quit()

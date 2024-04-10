extends Node2D


func _on_player_hit_body_entered(body):
	if body.name == "Player":
		print("Dead")
		get_tree().reload_current_scene()

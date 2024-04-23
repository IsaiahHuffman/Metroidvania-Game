extends AnimatableBody2D

func _ready():
	$AnimationPlayer.play("Move") # this plays the animation that updates its position

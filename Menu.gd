extends Node2D

var scene_moved = false

func _ready():
	set_process(true)

func _process(delta):
	if (Input.is_action_pressed("start_game") and not scene_moved):
		scene_moved = true
		get_node("Button/Blink").play("Pressed")
		get_node("Fade").play("Fade")

func _move_scene():
	get_tree().change_scene("res://Game.tscn")

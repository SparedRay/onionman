extends Node2D

var scene_moved = false
var credits_text
var credits_index = 0

const credits = [
	"Programming by SparedRay",
	"Characters thanks to GrafxKid",
	"Game made for OGA Jam"
]

func _ready():
	credits_text = get_node("Button/Credits")
	set_process(true)

func _process(delta):
	if (Input.is_action_pressed("start_game") and not scene_moved):
		scene_moved = true
		get_node("Button/Blink").play("Pressed")
		get_node("Fade").play("Fade")

func _update_credits():
	credits_text.set_text(credits[credits_index])
	credits_index += 1
	if (credits_index == credits.size()):
		credits_index = 0

func _move_scene():
	get_tree().change_scene("res://Game.tscn")

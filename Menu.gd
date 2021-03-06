extends Node2D

var scene_moved = false
var credits_text
var credits_index = 0
var c

const credits = [
	"Programmed by SparedRay",
	"Characters thanks to GrafxKid",
	"Music made by ViRIX and Crateboy",
	"Game made for OGA Jam"
]

func _ready():
	c = get_node("/root/Controller")
	c.ui.hide()
	credits_text = get_node("Button/Credits")
	set_process(true)

func _process(delta):
	if (Input.is_action_pressed("start_game") and not scene_moved):
		scene_moved = true
		get_node("Button/Blink").play("Pressed")
		get_node("Button/Sound").play("sfx_select")
		c.begin_cutscene()
		c.root.change_map("res://Story/Intro.tscn",0)

func _update_credits():
	credits_text.set_text(credits[credits_index])
	credits_index += 1
	if (credits_index == credits.size()):
		credits_index = 0

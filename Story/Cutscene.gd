extends Area2D

var player_class = preload("res://Entity/Player.gd")
var controller
var text = ["Mmm una escena de texto", "Con dos lineas!"]
var check = null
var cutscene = true
var do_text = true

func _ready():
	controller = get_node("/root/Controller")
	connect("body_enter",self,"_on_Area2D_body_enter")
	pass

func _on_Area2D_body_enter( body ):
	if (body extends player_class):
		var test = get_node("/root/Global").checks
		if (check == null or (check != null and not test[check])):
			show()
			if (cutscene):
				controller.begin_cutscene()
			if (check != null):
				test[check] = true
			if (do_text):
				controller.show_text(text)

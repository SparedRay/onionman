extends Node2D

var hp = 1
var score = 0
var dead = false
var attack = preload("res://Entity/Attack.gd")
var smoke_effects = preload("res://Entity/Effects/Smoke.tscn")
var score_effect = preload("res://Entity/Effects/Score.tscn")
var controller
var sound

func _ready():
	controller = get_node("/root/Controller")
	sound = get_node("/root/SoundManager")
	get_node("Hitbox").connect("body_enter", self, "_on_Hitbox_body_enter")
	set_fixed_process(true)

func _on_Hitbox_body_enter( body ):
	if (body extends attack):
		_get_hit()
		sound.play_sfx("hit",true)
		var controller = get_node("/root/Controller")
		var map = controller.current_map
		var player = controller.get_player()
		controller.is_shaking = true
		if (hp <= 0 and not dead):
			_death()

func _death():
	dead = true
	var instance = smoke_effects.instance()
	var player = controller.get_player()
	var score_instance = score_effect.instance()
	controller.current_map.add_child(instance)
	instance.play()
	instance.set_global_pos(get_global_pos()-Vector2(0,16))
	instance.set_scale(Vector2(1 - 2*player.sees_left,1))
	controller.current_map.add_child(score_instance)
	score_instance.set_global_pos(get_global_pos()-Vector2(0,-8))
	score_instance.play(score)
	controller.is_shaking = true
	sound.play_sfx("woosh-3",true)
	controller.get_player()._update_score(score, false)
	queue_free()

func _get_hit():
	hp -= 1
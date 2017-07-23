extends Node

var root

var lf_active = true
var full_lifeforce = true
var lifeforce_timer
var death = false
var lf_time = 8
const LF_UP = 3
var progress

var map_layer
var current_map = null
var current_map_name = null
var checkpoint = 0
var player

var ui
var fader
var bosshp
var face_anim
var text_win

var camera
var cam_collision
var cam_target = null
var player_class = preload("res://Entity/Player.gd")
var is_shaking
var shake_state = "none"
const CAM_OFFSET = -16
const CAM_HSTR = 3
const CAM_VSTR = 12
const CAM_CUTS = 12

var snd_manager

var cutscene = false
var press_full = false

func _ready():
	OS.set_window_maximized(true)
	randomize()
	var _root=get_tree().get_root()
	root = _root.get_child(_root.get_child_count()-1)
	lifeforce_timer = root.get_node("LifeforceTimer")
	progress = get_node("/root/Global")
	ui = root.get_node("UI/Inner")
	bosshp = ui.get_node("BossHP")
	fader = root.get_node("UI/Transition/Animation")
	face_anim = ui.get_node("FaceAnim")
	text_win = ui.get_node("TextWindow")
	map_layer = root.get_node("Map")
	camera = root.get_node("Map/Camera")
	camera.make_current()
	snd_manager = get_node("/root/SoundManager")
	set_fixed_process(true)

func _fixed_process(delta):
	if (cam_target != null):
		scroll_camera()
	else:
		camera.set_pos(Vector2(160,90))

	if (is_shaking):
		cam_shake()
	if (Input.is_action_pressed("exit")):
		get_tree().quit()
	if (!Input.is_action_pressed("fullscreen")):
		press_full = false
	elif (not press_full and Input.is_action_pressed("fullscreen")):
		press_full = true
		if (OS.is_window_fullscreen()):
			OS.set_window_fullscreen(false)
		else:
			OS.set_window_fullscreen(true)
	
	ui.get_node("Frame").get_node("Coins").get_node("Pts").set_text("%04d" % progress.total_coins)
	ui.get_node("Frame").get_node("Score").get_node("Pts").set_text("%07d" % progress.total_score)

func life_up():
	var time = lf_time - LF_UP * progress.checks["1ShieldUpgrade"]
	time -= LF_UP * LF_UP * progress.checks["2ShieldUpgrade"] + LF_UP * progress.checks["3ShieldUpgrade"]
	if (not full_lifeforce):
		snd_manager.play_sfx("ding")
	full_lifeforce = true
	lifeforce_timer.stop()
	lifeforce_timer.set_wait_time(time)

func life_down():
	if (not death):
		change_face("Hurt")
		if (not full_lifeforce):
			death = true
			get_player().death()
			lifeforce_timer.stop()
			root.get_node("DeathTimer").start()
		else:
			snd_manager.play_sfx("hit",true)
			lifeforce_timer.start()
			full_lifeforce = false

func get_player():
	var player_array = get_tree().get_nodes_in_group("Player")
	return player_array[player_array.size()-1]

func scroll_camera():
	# Distancia de la camara al jugador
	var pos = camera.get_global_pos()
	var opos = cam_target.get_global_pos()
	opos.y += CAM_OFFSET
	var dist = opos - pos
	dist = Vector2(round(dist.x),round(dist.y))
	var move = Vector2(dist.x/(CAM_HSTR + CAM_CUTS*(cam_target != player)), dist.y/CAM_VSTR)

	if (abs(move.x) < 1):
		move.x = sign(move.x)
	if (abs(move.y) < 1):
		move.y = sign(move.y)
	
	if (dist.x != 0):
		pos.x += move.x
	
	if (dist.y != 0):
		pos.y += move.y
#	
	pos.y = round(pos.y)
	pos.x = round(pos.x)
	
	camera.set_pos(pos)

func cam_shake():
	if (shake_state == "none"):
		camera.set_offset(Vector2(-2,-2))
		shake_state = "tl"
	elif (shake_state == "tl"):
		camera.set_offset(Vector2(0,0))
		shake_state = "zero"
	elif (shake_state == "zero"):
		camera.set_offset(Vector2(2,2))
		shake_state = "br"
	elif (shake_state == "br"):
		camera.set_offset(Vector2(0,0))
		is_shaking = false
		shake_state = "none"

func show_text(text):
	text_win.show_text(text)

func change_face(text):
	print("Face Anim")
#	face_anim.play(text)
#	face_anim.queue("Neutral")
	
func begin_cutscene():
	cutscene = true

func end_cutscene():
	cutscene = false

func show_bosshp(value):
	bosshp.show()
	bosshp.top = value
	bosshp.current = 0

func hide_bosshp():
	bosshp.hide()
	bosshp.top = 1
	bosshp.current = 0
	bosshp.bar.set_value(0)
extends Node2D

const map_names = { "res://Menu.tscn":"Title",
					"res://Story/Intro.tscn":"Intro",
					"res://Worlds/World1.tscn":"World1",
					"res://Story/World1_end.tscn":"World1_end"}
const map_songs = {	"World1":"res://UI/Music/mushroom_dance.ogg",
					"Intro":"res://UI/Music/Grasslands Theme.ogg",
					"Title":"res://UI/Music/Busy Day At The Market-LOOP.ogg",
					"World1_end":"res://UI/Music/act1_end.ogg",
					"gameover":null, }

var c
var load_state = 0
var load_timer
var tmap
var tcp

func _ready():
	c = get_node("/root/Controller")
	load_timer = get_node("LoadTimer")
	change_map("res://Menu.tscn", 0)
	
func _on_Timer_timeout():
	c.life_up()

func _on_DeathTimer_timeout():
	c.death = false
	change_map(c.current_map_name, c.checkpoint)
	var map_song = map_songs[map_names[c.current_map_name]]
	if (c.snd_manager.get_stream().get_path() != map_song):
		c.snd_manager.change_song(map_song)

func change_map(map, cp):
	if (load_state == 0):
		if (c.current_map_name != map):
			var song = map_songs[map_names[map]]
			if (song != null):
				c.snd_manager.change_song(song)
		c.begin_cutscene()
		if (c.current_map!=null):
			c.fader.play("Out")
			c.ui.hide()
		load_timer.set_wait_time(0.75)
		load_timer.start()
		tmap = map
		tcp = cp
		load_state = 1
	elif (load_state == 1):
		c.cam_target = null
		if (c.current_map!=null):
			c.current_map.queue_free()
			c.current_map.set_name(c.current_map.get_name() + "_deleted" )
		var m = load(map)
		c.checkpoint = cp
		c.current_map = m.instance()
		c.current_map_name = map
		c.map_layer.add_child(c.current_map)
		c.hide_bosshp()
		c.life_up()
		c.lifeforce_timer.stop()
		for cps in get_tree().get_nodes_in_group("Checkpoints"):
				if (cps.id == c.checkpoint):
					c.player = c.get_player()
					c.player.set_global_pos(cps.get_global_pos()-Vector2(0,-1))
		load_timer.set_wait_time(0.25)
		load_timer.start()
		load_state = 2
	else:
		c.end_cutscene()
		if (map_names[c.current_map_name] == "World1"):
			c.ui.show()
			get_node("UI/Inner/Clock/Timer").start()
		c.fader.play("In")
		load_state = 0

func _on_LoadTimer_timeout():
	change_map(tmap, tcp)
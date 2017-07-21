extends RigidBody2D

const STATE_WALKING = 0
const STATE_WAITING = 1
const STATE_STUNT = 2
const STATE_DYING = 3
const STATE_CHARGE = 4

var Global

var boss_life = 3
var state = null
var direction = -1
var anim = ""

var rc_left = null
var rc_right = null
var WALK_SPEED = 400
var init_shape = []
var smokeParticles

var refill_timer
var player_class = preload("res://Entity/Player.gd")

func _die():
	queue_free()

func _pre_die():
	clear_shapes()
	set_mode(MODE_STATIC)

func _damaged():
	boss_life -= 1
	print("Damaged")
	state = STATE_CHARGE
	anim = "Hit"
	get_node("Animation").play(anim)
	refill_timer.set_wait_time(3)
	refill_timer.start()

func _invert_direction():
	direction = -direction
	smokeParticles.set_scale(Vector2(-direction, 1))
	if (direction > 0):
		get_node("Sprite").set_flip_h(true)
	else:
		get_node("Sprite").set_flip_h(false)
	state = STATE_STUNT
	print("Stuned")
	smokeParticles.set_emitting(false)
	refill_timer.start()

func _init_boss():
	state = STATE_WALKING

func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var new_anim = anim
	
	if (state == STATE_DYING):
		new_anim = "Die"
	elif (state == STATE_STUNT):
		new_anim = "Stunt"
		var kill = false
		for x in range(s.get_contact_count()):
			var cc = s.get_contact_collider_object(x)
			var dp = s.get_contact_local_normal(x)
			kill = _handle_player_collide(cc, dp, false, true)
			if (kill):
				break
		
		if (kill):
			_damaged()
	elif (state == STATE_WAITING):
		new_anim = "Run"
		
		if (get_global_pos().x > Global.player_pos.x):
			direction = -1
		else:
			direction = 1
		
		smokeParticles.set_scale(Vector2(-direction, 1))
		if (direction > 0):
			get_node("Sprite").set_flip_h(true)
		else:
			get_node("Sprite").set_flip_h(false)
		
		for x in range(s.get_contact_count()):
			var cc = s.get_contact_collider_object(x)
			var dp = s.get_contact_local_normal(x)
			_handle_player_collide(cc, dp, false, false)
	elif (state == STATE_WALKING):
		new_anim = "Run"
		
		var wall_side = 0.0
		for x in range(s.get_contact_count()):
			var cc = s.get_contact_collider_object(x)
			var dp = s.get_contact_local_normal(x)
			
			_handle_player_collide(cc, dp, false, false)
			
			if (dp.x > 0.9):
				wall_side = 1.0
			elif (dp.x < -0.9):
				wall_side = -1.0
		
		if (wall_side != 0 and wall_side != direction):
			_invert_direction()
		
		if (direction < 0 and not rc_left.is_colliding() and rc_right.is_colliding()):
			_invert_direction()
		elif (direction > 0 and not rc_right.is_colliding() and rc_left.is_colliding()):
			_invert_direction()
		
		lv.x = direction*WALK_SPEED
	
	if (anim != new_anim):
		anim = new_anim
		get_node("Animation").play(anim)
	
	s.set_linear_velocity(lv)

func _handle_player_collide(body, dp, killBoth, killEnemy):
	if (not body):
		return
	
	var collide = false
	if (killBoth):
		if (body extends player_class and dp.y > 0.9):
			#set_mode(MODE_RIGID)
			#set_friction(1)
			body.update_score(200, false)
			get_node("Sound").play("woosh-3")
			collide = true
		elif (body extends player_class):
			body.sound_node.play("death")
			body._dying()
	elif (killEnemy):
		if (body extends player_class and dp.y > 0.9):
			set_mode(MODE_RIGID)
			#set_friction(1)
			body.update_score(200, false)
			get_node("Sound").play("woosh-3")
			collide = true
	else:
		if (body extends player_class):
			body.sound_node.play("death")
			body._dying()
	
	return collide
	
func _ready():
	rc_left = get_node("Raycast_left")
	rc_right = get_node("Raycast_right")
	refill_timer = get_node("Refill")
	smokeParticles = get_node("Smoke")
	init_shape = []
	for i in range(get_shape_count()):
		init_shape.append(get_shape(i))
	
	
	Global = get_node("/root/Global")

func _on_Refill_timeout():
	print("Timeout")
	
	if (state == STATE_WAITING):
		smokeParticles.set_randomness(Particles2D.PARAM_FINAL_SIZE, 1.0)
		state = STATE_WALKING
		print("Walking")
		get_node("Sound").play("steam")
	elif (state == STATE_STUNT || state == STATE_CHARGE):
		smokeParticles.set_randomness(Particles2D.PARAM_FINAL_SIZE, 0.0)
		smokeParticles.set_emitting(true)
		state = STATE_WAITING
		print("Waiting")
		set_mode(MODE_CHARACTER)
		refill_timer.set_wait_time(5)
		refill_timer.start()


func _on_BossEnabler_enter_screen():
	print("En pantalla")
	_init_boss()

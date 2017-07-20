extends RigidBody2D

const initial_pos = Vector2(50.0, 670.0)
var base_shape

var anim = ""
var siding_left = false
var jumping = false
var stopping_jump = false
var stop_jumping = false

var RUN_ACCEL = 3000.0
var RUN_DEACCEL = 3000.0
var RUN_MAX_VELOCITY = 180.0
var AIR_ACCEL = 2000.0
var AIR_DEACCEL = 2500.0
var JUMP_VELOCITY = 260
var STOP_JUMP_FORCE = 950.0

var MAX_FLOOR_AIRBONE_TIME = 0.15
var airbone_time = 1e20

var floor_h_velocity = 0.0
var enemy

var current_score = 0
var sound_node

func _ready():
	get_node("UI/Transition/Animation").play("In")
	sound_node = get_node("Sound")
	base_shape = get_shape(0)

func update_score(pts, coin):
	if (coin):
		var coin_count = get_node("UI/Coins/Pts")
		var coin_nr = coin_count.get_text().to_int()
		var new_count = coin_nr + 1
		coin_count.set_text("%04d" % new_count)

	current_score += pts
	var score_count = get_node("UI/Score/Pts")
	score_count.set_text("%08d" % current_score)
	

func _die():
	print("Muerto")
	# queue_free()

func _dying():
	if (get_node("UI/Timer").time_left > 0.1):
		get_node("UI/Timer").stop()
	clear_shapes()
	set_mode(MODE_STATIC)
	anim = "Dying"
	get_node("Anim").play(anim)

func _revive():
	get_node("UI/Timer").start()
	add_shape(base_shape)
	set_mode(MODE_CHARACTER)
	anim = "Idle"
	get_node("PlayerLabel").set_hidden(false)
	get_node("Anim").play(anim)
	get_node("Sprite").set_offset(Vector2(0, 0))
	current_score = 0
	var coin_count = get_node("UI/Coins/Pts")
	coin_count.set_text("%04d" % 0)
	update_score(0, false)
	set_pos(initial_pos)

func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var step = s.get_step()
	
	var new_anim = anim
	var new_siding_left = siding_left
	
	# Sacanmos los controles
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_pressed("jump")
	
	# Se ajusta basado en la velocidad anterior
	lv.x -= floor_h_velocity
	floor_h_velocity = 0.0
	
	# Revisamos si hay colision
	var found_floor = false
	var floor_index = -1
	for x in range(s.get_contact_count()):
		var ci = s.get_contact_local_normal(x)
		if(ci.dot(Vector2(0, -1)) > 0.6):
			found_floor = true
			floor_index = x
	
	if (found_floor):
		airbone_time = 0.0
	else:
		airbone_time += step # Tiempo en el aire
	
	var on_floor = airbone_time < MAX_FLOOR_AIRBONE_TIME
	
	if (jumping):
		if (move_left and not move_right):
			get_node("Sprite").set_scale(Vector2(-1, 1))
		if (move_right and not move_left):
			get_node("Sprite").set_scale(Vector2(1, 1))
		
		if (lv.y > 0):
			# Apaga la bandera de salto
			jumping = false
		elif (not jump):
			stopping_jump = true
		
		if(stopping_jump):
			lv.y += STOP_JUMP_FORCE*step
	
	if(on_floor):
		# Logica cuando esta en el suelo
		if (move_left and not move_right):
			if(lv.x > -RUN_MAX_VELOCITY):
				lv.x -= RUN_ACCEL*step
		elif (move_right and not move_left):
			if(lv.x < RUN_MAX_VELOCITY):
				lv.x += RUN_ACCEL*step
		else:
			var xv = abs(lv.x)
			xv -= RUN_DEACCEL*step
			if(xv < 0):
				xv = 0
			lv.x = sign(lv.x)*xv
		
		# Verificamos el salto
		if (not jumping and jump):
			lv.y = -JUMP_VELOCITY
			jumping = true
			stopping_jump = false
			sound_node.play("sfx_jump")
		
		# Revisar la direccino del sprite
		if (lv.x < 0 and move_left):
			new_siding_left = true
		elif (lv.x > 0 and move_right):
			new_siding_left = false
		if (jumping):
			new_anim = "Jumping"
		elif (abs(lv.x) < 0.1):
			new_anim = "Idle"
		else:
			new_anim = "Run"
	else:
		# Logica cuando el personaje esta en el aire
		if (move_left and not move_right):
			if(lv.x > -RUN_MAX_VELOCITY):
				lv.x -= AIR_ACCEL*step
		elif (move_right and not move_left):
			if(lv.x < RUN_MAX_VELOCITY):
				lv.x += AIR_ACCEL*step
		else:
			var xv = abs(lv.x)
			xv -= AIR_DEACCEL*step
			if (xv < 0):
				xv = 0
			lv.x = sign(lv.x)*xv
		
		if(lv.y < 0):
			new_anim = "Jumping"
		else:
			new_anim = "Falling"
	
	# Se actualiza la direccion
	if (new_siding_left != siding_left):
		if(new_siding_left):
			get_node("Sprite").set_scale(Vector2(-1, 1))
		else:
			get_node("Sprite").set_scale(Vector2(1, 1))
		
		siding_left = new_siding_left
	
	# Se actualiza la animacion
	if (new_anim != anim):
		anim = new_anim
		get_node("Anim").play(anim)
	
	# Aplicar velocidad en funcion del suelo
	if (found_floor):
		floor_h_velocity = s.get_contact_collider_velocity_at_pos(floor_index).x
		lv.x += floor_h_velocity
	
	# Aplicamos gravedad lineal
	lv += s.get_total_gravity()*step
	s.set_linear_velocity(lv)
	
	if (get_pos().y > 800):
		sound_node.play("fall_death")
		_dying()

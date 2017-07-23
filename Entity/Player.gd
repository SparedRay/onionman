extends KinematicBody2D

const GRAVITY = 650.0
const FLOOR_ANGLE = 40
const WALK_FORCE = 600
const WALK_MIN = 10
const WALK_MAX = 200
const STOP_FORCE = 1300
const STOP_COEFF = 0.65
const MAX_JUMP = 0.105
const JUMP_VEL = 220
const MAX_AIR = 0.1 # Tolerancia de suelo
const FALL_ANIM_HEIGHT = 0

export var attacking = false
export var create_hit = false
export var need_synchro = false

var velocity = Vector2()
var jumping = false
var can_jump = true
var falling = false
var can_attack = true
var air_time = 100
var jump_time

var walk_left
var walk_right
var walk_up
var walk_down
var jump
var attack

var hurtful_class = preload("res://Entity/Hurtful.gd")
var killer_class = preload("res://Entity/Killer.gd")
var enemy_class = preload("res://Entity/Enemy.gd")
export var vulnerable = true
var knockback = false
var box_hit = preload("res://Entity/Hit.tscn")
var attack_spot
var aspd
var strong_slash

var sees_left = false
var sprite
var effects
var dust = preload("res://Entity/Effects/Dust.tscn")
var landed = false
var stopped = false

var smoke_effects = preload("res://Entity/Effects/Smoke.tscn")
var dead = false

var sfx

var controller
var cutscene = false
var global

func _ready():
	global = get_node("/root/Global")
	jump_time = get_node("Jump")
	jump_time.set_wait_time(MAX_JUMP)
	controller = get_node("/root/Controller")
	aspd = global.checks["AttackSpeedUpgrade"]
	strong_slash = global.checks["StrongSlash"]
	sfx = get_node("Sound")
	controller.cam_target = self
	attack_spot = get_node("AttackSpot")
	effects = get_node("Effects")
	sprite = get_node("Animation")
	controller.ui.show()
	
	set_fixed_process(true)

func _fixed_process(delta):
	cutscene = controller.cutscene
	if(not cutscene):
		walk_left = Input.is_action_pressed("move_left")
		walk_right = Input.is_action_pressed("move_right")
		walk_up = Input.is_action_pressed("ui_up")
		walk_down = Input.is_action_pressed("ui_down")
		jump = Input.is_action_pressed("jump")
		attack = Input.is_action_pressed("attack")
	else:
		walk_left = false
		walk_right = false
		walk_up = false
		walk_down = false
		jump = false
		attack = false
	if (not dead):
		_movement(delta)
	
	if (get_pos().y > 800):
		controller.life_down()
		controller.life_down()

func _movement(delta):
	# Gravedad
	var force = Vector2(0,GRAVITY)
	# Inercia
	var stop = true
	# Direccion de movimiento
	if (walk_left and not walk_right):
		if (velocity.x<=WALK_MIN and velocity.x > -WALK_MAX):
			force.x-=WALK_FORCE
			stop = false
			stopped = false
			if (sprite.get_current_animation() != "Run" and !jumping && !falling):
				sprite.play("Run")
		else:
			force.x = -WALK_FORCE * STOP_COEFF
	elif (walk_right and not walk_left):
		if (velocity.x>=-WALK_MIN and velocity.x < WALK_MAX):
			force.x+=WALK_FORCE
			stop = false
			stopped = false
			if (sprite.get_current_animation() != "Run" and !jumping && !falling):
				sprite.play("Run")
		else:
			force.x = WALK_FORCE * STOP_COEFF
	
	if (stop):
		stop(delta)

	# Calcular el movimiento
	velocity += force * delta
	var motion = velocity * delta
	motion = move(motion)
	
	
	if (is_colliding()):
		var n = get_collision_normal()
		
		if ( rad2deg(acos(n.dot( Vector2(0,-1)))) < FLOOR_ANGLE ):
#			Se compara con el valor de tolenrancia
			air_time=0
			falling = false
			if (not landed):
				create_dust("Land")
				sfx.play("step")
				landed = true
		
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		
		move(motion)

	air_time+=delta
	
	if (jumping and velocity.y>=0):
		falling = true
		jumping=false
		
	if (velocity.y > 0 and air_time > MAX_AIR):
		falling = true
	
	if (velocity.y < 0 and sprite.get_current_animation() != "Jump"):
		sprite.play("Jump")

	if (falling and sprite.get_current_animation() != "Fall"):
		sprite.play("Fall")

	# Control de salto
	if (!jump):
		can_jump = true
	elif (not jumping and can_jump and jump and not falling):
		can_jump = false
		sfx.play("sfx_jump")
		create_dust("Jump")
		sprite.play("Jump")
		jumping=true
		jump_time.start()
		velocity.y = -JUMP_VEL

	# Controlamos el ataque
	if (!attack):
		can_attack = true
	elif (can_attack and falling && !attacking):
		can_attack = false
		attack()

	if (create_hit):
		create_hit = false
		attack_spot.add_child(box_hit.instance())
	
	if (velocity.x>0):
		sees_left = false
	elif (velocity.x<0):
		sees_left = true
	if (sees_left):
		get_node("Sprite").set_scale(Vector2(-1,1))
	else:
		get_node("Sprite").set_scale(Vector2(1,1))

	# Estados del "Dust"
	if (landed and (jumping or falling)):
		landed = false

	if (attacking and !is_attacking()):
		attacking = false
		attack_spot.get_child(0).queue_free()

func stop(delta):
	var vsign = sign(velocity.x)
	var vx = abs(velocity.x)
	vx -= STOP_FORCE * delta
	if (vx<0):
		vx=0
		if (sprite.get_current_animation() != "Idle" && sprite.get_current_animation() != "Victory" && !jumping && !falling):
			if (not stopped and not jumping and not falling):
				create_dust("Brake")
				stopped = true
			sprite.play("Idle")
	velocity.x=vx*vsign

func attack():
	attacking = true

# Idea para el futuro
func strong_attack():
		attacking = true
		#attack_spot.add_child(strong_hit.instance())
		sprite.play("StrongAttack")

func is_attacking():
	return falling

func create_dust(type):
	var map = controller.current_map
	var instance = dust.instance()
	instance.play(type)
	map.add_child(instance)
	instance.set_global_pos(get_global_pos()+Vector2(0,-8))
	instance.set_scale(Vector2(1 - 2*sees_left,1))

func _on_Hitbox_body_enter( body ):
	if (body extends hurtful_class):
		if (not dead and vulnerable):
			vulnerable = false
			effects.play("Invulnerable")
			controller.life_down()
	elif (body extends killer_class):
		if (not dead):
			controller.life_down()
			controller.life_down()

func death():
	dead = true
	var map = controller.current_map
	var instance = smoke_effects.instance()
	map.add_child(instance)
	get_node("/root/SoundManager").play_sfx("smoke",true)
	instance.play()
	instance.set_global_pos(get_global_pos()-Vector2(0,16))
	instance.set_scale(Vector2(1 - 2*sees_left,1))
	hide()
	sprite.stop()

func _on_Jump_timeout():
	if (jump):
		velocity.y = -JUMP_VEL

func _update_score(score, is_coin):
	if (is_coin):
		global.total_coins += 1
	global.total_score += score

extends "Enemy.gd"

const R = -1
const L = 1
const MIN_TURN = 2
const MAX_TURN = 4
const IDLE = 0
const WAIT_IDLE = 1
const RUN = 2
const REST = 3

var max_hp = 300
var state = IDLE
var turns = 0
var speed = 5
var active = false
var direction
var anim
var timer
var detect
var marker = preload("res://Entity/Mark.gd")
var bullet = preload("res://Entity/Bullet.tscn")

func _ready():
	hp = max_hp
	direction = L
	set_scale(Vector2(direction, 1))
	detect = get_node("Detect")
	anim = get_node("Animation")
	timer = get_node("Timer")

func _fixed_process(delta):
	if (active):
		if (state == IDLE):
			turns = randi() % (MAX_TURN - MIN_TURN) + MIN_TURN
			
			state = WAIT_IDLE
			timer.start()
		elif (state == RUN):
			var pos = get_pos() + Vector2(speed * -direction, 0)
			set_pos(pos)

func _on_Detect_body_enter( body ):
	if (body extends marker):
		if (turns < 0):
			direction *= -1
			set_scale(Vector2(direction, 1))
			turns -= 1
		else:
			state = REST
			
			anim.play("Stunned")
			timer.start()

func _on_Timer_timeout():
	if (state == WAIT_IDLE):
		anim.play("Run")
		state = RUN
	elif (state == REST):
		direction *= -1
		set_scale(Vector2(direction, 1))
		anim.play("Shoot")
		state = IDLE

func shoot():
	var pos = get_node("Position2D").get_global_pos()
	var inst = bullet.instance()
	inst.set_pos(pos)
	var parent = get_parent()
	while (parent.get_node("Player") == null):
		parent = parent.get_parent()
	parent.add_child(inst)

func _death():
	active = false
	state = 99
	
	print("Dead")
	dead = true
	get_node("Hitbox").queue_free()
	get_node("Hurtbox").queue_free()

func rumble():
	sound.play_sfx("rumble")
	
func shake():
	controller.is_shaking = true
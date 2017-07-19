extends RigidBody2D

const STATE_WALKING = 0
const STATE_DYING = 1

var state = STATE_WALKING
var direction = -1
var anim = ""

var rc_left = null
var rc_right = null
var WALK_SPEED = 50

var player_class = preload("res://Entity/Player.gd")

func _die():
	queue_free()

func _pre_die():
	clear_shapes()
	set_mode(MODE_STATIC)

func _invert_direction():
	direction = -direction
	get_node("Sprite").set_scale(Vector2(-direction, 1))

func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var new_anim = anim
	
	if (state == STATE_DYING):
		new_anim = "Die"
	elif (state == STATE_WALKING):
		new_anim = "Run"
		
		var wall_side = 0.0
		for x in range(s.get_contact_count()):
			var cc = s.get_contact_collider_object(x)
			var dp = s.get_contact_local_normal(x)
			
			if (cc):
				if (cc extends player_class and dp.y > 0.8):
					set_mode(MODE_RIGID)
					state = STATE_DYING
					set_friction(1)
					cc.update_score(200, false)
					get_node("Sound").play("woosh-3")
					break
				elif (cc extends player_class):
					cc.sound_node.play("death")
					cc._dying()
			
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

func _ready():
	rc_left = get_node("Raycast_left")
	rc_right = get_node("Raycast_right")

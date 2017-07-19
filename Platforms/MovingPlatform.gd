extends Node2D

export var motion = Vector2()
export var cycle = 1.0
var accum = 0.0

func _fixed_process(delta):
	accum += delta*(1.0/cycle)*PI*2.0
	accum = fmod(accum, PI*2.0)
	var d = sin(accum)
	var xf = Matrix32()
	xf[2] = motion*d
	get_node("Platform").set_transform(xf)

func _ready():
	set_fixed_process(true)
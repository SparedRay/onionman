extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var blocks = [
	preload("res://Platforms/block1.tscn"),
#	preload("res://Platforms/block2.tscn"),
	preload("res://Platforms/block3.tscn"),
#	preload("res://Platforms/block4.tscn"),
#	preload("res://Platforms/block5.tscn"),
#	preload("res://Platforms/block6.tscn"),
#	preload("res://Platforms/block7.tscn"),
#	preload("res://Platforms/block8.tscn"),
#	preload("res://Platforms/block9.tscn")
]
var last_block_used = null
var last_block_x = 0.0
const INIT_Y = 704

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var tilemap = get_parent().get_node("TileMap")
	var size = tilemap.get_used_rect()
	last_block_x = size.size.x*tilemap.get_cell_size().x
	
	for b in range(1):
		randomize()
		var rndGap = floor(rand_range(0, 5))*tilemap.get_cell_size().x
		var rndBlock = floor(rand_range(0, blocks.size()))
		while (last_block_used == rndBlock):
			randomize()
			rndBlock = floor(rand_range(0, blocks.size()))
		last_block_used = rndBlock
		var block = blocks[rndBlock]
		var new_block = block.instance()
		var new_x = last_block_x + rndGap
		var new_y = INIT_Y
		new_block.set_pos(Vector2(new_x, new_y))
		get_node(".").add_child(new_block)
		last_block_x = new_x + new_block.get_used_rect().size.x*tilemap.get_cell_size().x
	
	# Agregando nivel del boss
	randomize()
	var rndGap = floor(rand_range(0, 5))*tilemap.get_cell_size().x
	var block = preload("res://Platforms/BossFight.tscn")
	var new_block = block.instance()
	var new_x = last_block_x + rndGap
	new_block.set_pos(Vector2(new_x, INIT_Y))
	get_node(".").add_child(new_block)
	# print("Parent: " + String(size))
	#for c in get_node(".").get_children():
	#	var s = c.get_used_rect()
	#	print("Hijo " + c.get_name() + ": " + String(s))
	pass

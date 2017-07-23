extends Node2D

var global_seed

var blocks = [
	preload("res://Platforms/block1.tscn"),
	preload("res://Platforms/block2.tscn"),
	preload("res://Platforms/block3.tscn"),
	preload("res://Platforms/block4.tscn"),
	preload("res://Platforms/block5.tscn"),
	preload("res://Platforms/block6.tscn"),
	preload("res://Platforms/block7.tscn"),
	preload("res://Platforms/block8.tscn"),
	preload("res://Platforms/block9.tscn")
]
var last_block_used = null
var last_block_x = 0.0
var tilemap
const INIT_Y = 704

func _ready():
	global_seed = get_node("/root/Global").seeder
	tilemap = get_parent().get_node("TileMap")
	var size = tilemap.get_used_rect()
	last_block_x = size.size.x*tilemap.get_cell_size().x
	if (global_seed.size() < 1):
		_gen_map()
	else:
		_seed_map()
	
	get_node("/root/Global").seeder = global_seed

func _gen_map():
	for b in range(12):
		randomize()
		var gap = floor(rand_range(0, 5))
		var rndGap = gap*tilemap.get_cell_size().x
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
		var used_rect = new_block.get_used_rect()
		last_block_x = new_x + used_rect.size.x*tilemap.get_cell_size().x
		global_seed.append([gap, block])
	
	# Agregando nivel del boss
	randomize()
	var gap = floor(rand_range(0, 5))
	var rndGap = gap*tilemap.get_cell_size().x
	var block = preload("res://Platforms/BossFight.tscn")
	global_seed.append([gap, block])
	var new_block = block.instance()
	var new_x = last_block_x + rndGap
	new_block.set_pos(Vector2(new_x, INIT_Y))
	get_node(".").add_child(new_block)

func _seed_map():
	for seeder in global_seed:
		var gap = seeder[0]
		var rndGap = gap*tilemap.get_cell_size().x
		var block = seeder[1]
		var new_block = block.instance()
		var new_x = last_block_x + rndGap
		var new_y = INIT_Y
		new_block.set_pos(Vector2(new_x, new_y))
		get_node(".").add_child(new_block)
		var used_rect = new_block.get_used_rect()
		last_block_x = new_x + used_rect.size.x*tilemap.get_cell_size().x
	
	# Agregando nivel del boss
	var seeder = global_seed[global_seed.size() - 1]
	var gap = seeder[0]
	var rndGap = gap*tilemap.get_cell_size().x
	var block = seeder[1]
	var new_block = block.instance()
	var new_x = last_block_x + rndGap
	new_block.set_pos(Vector2(new_x, INIT_Y))
	get_node(".").add_child(new_block)

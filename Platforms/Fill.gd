extends TileMap

var coins_node
var enemies_node

func _generate_coins():
	for coin in coins_node.get_children():
		randomize()
		var set_coin = floor(rand_range(0, 2))
		if (set_coin != 0):
			coin.set_hidden(true)

func _generate_enemies():
	for enemy in enemies_node.get_children():
		randomize()
		var set_enemy = floor(rand_range(0, 2))
		if (set_enemy != 0):
			enemy._die()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	coins_node = get_node("Coins")
	enemies_node = get_node("Enemies")
	_generate_coins()
	_generate_enemies()
	pass
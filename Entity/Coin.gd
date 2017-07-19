extends Area2D

# Revisar si fue tomada
var taken = false

func _on_Coin_body_enter( body ):
	if (is_visible() and not taken and body extends preload("res://Entity/Player.gd")):
		get_node("Animation").play("Taken")
		taken = true
		body.update_score(50, true)
		get_node("Sound").play("gold-4")

func _on_Coin_area_enter (area):
	pass

func _on_Coin_area_enter_shape (area_id, area, area_shape, area_shape):
	pass
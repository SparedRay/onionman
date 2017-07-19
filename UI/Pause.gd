extends TouchScreenButton

var paused = false
var fill
var continueButton
var retryButton
var transition

func _pause():
	if (not paused):
		fill.set_opacity(0.3)
		continueButton.set_hidden(false)
		continueButton.get_node("Anim").play("Blink")
		if (retryButton.is_visible()):
			retryButton.set_hidden(true)
		paused = true
		get_tree().set_pause(paused)
	else:
		fill.set_opacity(0)
		continueButton.set_hidden(true)
		continueButton.get_node("Anim").stop(true)
		if (retryButton.is_visible()):
			retryButton.set_hidden(true)
		paused = false
		get_tree().set_pause(paused)

func _retry():
	print("Retry")
	get_tree().change_scene("res://Game.tscn")

func _ready():
	fill = get_node("Fill")
	continueButton = get_node("ContinueButton")
	retryButton = get_node("RetryButton")
	transition = get_parent().get_node("Transition/Animation")

func _input(event):
	if (event.is_action_pressed("pause")):
		_pause()
	elif (event.is_action_pressed("reset")):
		transition.play("Out")

func _on_pause_pressed():
	_pause()

func _on_RetryButton_pressed():
	transition.play("Out")

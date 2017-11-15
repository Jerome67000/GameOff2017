extends Position2D

var free = true
signal spawn_new_dom

func _on_TimerPos1_timeout():
	emit_signal("spawn_new_dom")

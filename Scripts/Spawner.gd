extends Position2D

var free = true
signal _spawn_new_dom

func start_timer():
	$TimerPos.start()

func _on_TimerPos_timeout():
	var pos_num =  int(get_name().substr(3,1)) - 1
	emit_signal("_spawn_new_dom", pos_num)

extends Node2D

var panel_anchor
var values = {"top" : 0, "bottom" : 0}
var unique_id

signal _on_dom_can_move
signal _on_mouse_over_top
signal _on_mouse_over_bottom
signal _on_dom_placed


func set_values(top, bottom):
	unique_id = "#dom_t" + str(top) + "b" + str(bottom) + "_" + str(randi() % 1000 + 1)
	values.top = top
	values.bottom = bottom
	
	if top > 0:
		$Sprite/TopLabel.text = str(top)
	if bottom > 0:
		$Sprite/BottomLabel.text = str(bottom)
	
func bind_panel_anchor(anchor):
	panel_anchor = anchor
	
func reset_pos_and_rot():
	position = Vector2(0,0)
	$Sprite.rotation_deg = 0

func reparent_to(new_parent, at_pos):
	get_parent().call("start_timer")
	call_deferred("_deferred_reparent_to", new_parent, at_pos)


func _deferred_reparent_to(new_parent, at_pos):
	get_parent().remove_child(self)
	new_parent.add_child(self)
	position = at_pos
	
func get_dom_rotation():
	return get_node("Sprite").rotation_deg
	
func place_and_lock():
	self.set_pickable(false)
	emit_signal("_on_dom_placed", self)

func _on_Domino_mouse_entered():
	emit_signal("_on_dom_can_move", true, self)

func _on_Domino_mouse_exited():
	emit_signal("_on_dom_can_move", false, self)
	
	
func _on_TopPickableDetection_mouse_entered():
	emit_signal("on_mouse_over_top", true, true, self)

func _on_TopPickableDetection_mouse_exited():
	emit_signal("on_mouse_over_top", false, true, self)

func _on_BottomPickableDetection_mouse_entered():
	emit_signal("on_mouse_over_bottom", true, false, self)

func _on_BottomPickableDetection_mouse_exited():
	emit_signal("on_mouse_over_bottom", false, false, self)

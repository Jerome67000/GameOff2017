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
	$Tween.interpolate_property(self, "position", self.position, Vector2(0, 0), 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.interpolate_property($Sprite, "rotation_deg", $Sprite.rotation_deg, 0, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	
	set_clear_color()

func reparent_to(new_parent, at_pos):
	get_parent().call("start_timer")
	call_deferred("_deferred_reparent_to", new_parent, at_pos)

func _deferred_reparent_to(new_parent, at_pos):
	get_parent().remove_child(self)
	new_parent.add_child(self)
	position = at_pos
	
func droped():
	get_parent().call("start_timer")
	var dom_size = $Sprite.get_item_rect().size
	var dom_scale = $Sprite.scale
	self.edit_set_pivot(Vector2(0, dom_size.y*dom_scale.y*0.5))
	$Tween.interpolate_property(self, "scale", self.scale, Vector2(0, 0), 1, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "rotation_deg", self.rotation, 360, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.interpolate_property($Sprite, "modulate", $Sprite.modulate, Color($Sprite.modulate.r, $Sprite.modulate.g, $Sprite.modulate.b, 0), 1, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()

func rot_min_90():
	$Tween.interpolate_property($Sprite, "rotation_deg", $Sprite.rotation, 90, 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()

func set_good_color():
	$Sprite.modulate = Color(0,1,0)

func set_wrong_color():
	$Sprite.modulate = Color(1,0,0)

func set_clear_color():
	$Sprite.modulate = Color(1,1,1)
	
func valid_color():
	return $Sprite.modulate == Color(0,1,0)

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

extends Node2D

var anchor
var values = {"top" : 0, "bottom" : 0}
var unique_id
var used = false

signal on_dom_can_move
signal on_mouse_over_top
signal on_mouse_over_bottom

	
func set_values(top, bottom):
	unique_id = "#dom_t" + str(top) + "b" + str(bottom) + "_" + str(randi() % 1000 + 1)
	values.top = top
	values.bottom = bottom

	if top > 0:
		$Sprite/TopLabel.text = str(top)
	if bottom > 0:
		$Sprite/BottomLabel.text = str(bottom)


	
func init_position(anchor_param):
	anchor = anchor_param
	position = anchor.global_position
	
func reset_position():
	position = anchor.global_position
	$Sprite.rotation = 0

func _on_Domino_mouse_entered():
	emit_signal("on_dom_can_move", true, self)

func _on_Domino_mouse_exited():
	emit_signal("on_dom_can_move", false, self)
	
	
func _on_TopPickableDetection_mouse_entered():
	emit_signal("on_mouse_over_top", true, true, self)

func _on_TopPickableDetection_mouse_exited():
	emit_signal("on_mouse_over_top", false, true, self)

func _on_BottomPickableDetection_mouse_entered():
	emit_signal("on_mouse_over_bottom", true, false, self)

func _on_BottomPickableDetection_mouse_exited():
	emit_signal("on_mouse_over_bottom", false, false, self)

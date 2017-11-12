extends Node2D

onready var camera = $Player/"Camera2D"

var can_move = false
const initial_dom_count = 1
var current_dom
var dom_position
var clicked_pos = Vector2(0,0)
const magnet_threshold = 20
var must_magnet = false
var magnet_pos
var last_used_dom

var debug = true

func _ready():
	create_initial_dominoes()
	for num in range(initial_dom_count):
		domino_for_panel(num)
	
func _process(delta):
#	$Player.position.y += 50 * delta
	if debug:
		draw_debug()

func draw_debug():
	if current_dom != null:
		var curr_top = current_dom.get_node("Top")
		var last_bottom = last_used_dom.get_node("Bottom")
		var last_bottom_left = last_used_dom.get_node("BottomLeft")
		var last_bottom_right = last_used_dom.get_node("BottomRight")
				
		$Debug/LineBottom.set_point_position(0, curr_top.global_position)
		$Debug/LineBottom.set_point_position(1, last_bottom.global_position)
				
		$Debug/LineBottomLeft.set_point_position(0, curr_top.global_position)
		$Debug/LineBottomLeft.set_point_position(1, last_bottom_left.global_position)
				
		$Debug/LineBottomRight.set_point_position(0, curr_top.global_position)
		$Debug/LineBottomRight.set_point_position(1, last_bottom_right.global_position)
		
		var from_bot_dist = curr_top.global_position.distance_to(last_bottom.global_position)
		var from_botleft_dist = curr_top.global_position.distance_to(last_bottom_left.global_position)
		var from_botright_dist = curr_top.global_position.distance_to(last_bottom_right.global_position)
			
		if from_bot_dist < from_botleft_dist and from_bot_dist < from_botright_dist:
			$Debug/LineBottom.default_color = Color(0, 1, 0)
			$Debug/LineBottomLeft.default_color = Color(1, 0, 0)
			$Debug/LineBottomRight.default_color = Color(1, 0, 0)
			if from_bot_dist < magnet_threshold:
				must_magnet_to(last_bottom.global_position)
				current_dom.rotation_deg = 0
			else:
				must_magnet = false
	
		if from_botright_dist < from_bot_dist and from_botright_dist < from_botleft_dist:
			$Debug/LineBottom.default_color = Color(1, 0, 0)
			$Debug/LineBottomLeft.default_color = Color(1, 0, 0)
			$Debug/LineBottomRight.default_color = Color(0, 1, 0)
			if from_botright_dist < magnet_threshold:
				must_magnet_to(last_bottom_right.global_position)
				current_dom.rotation_deg = -90
			else:
				must_magnet = false
				
		if from_botleft_dist < from_bot_dist and from_botleft_dist < from_botright_dist:
			$Debug/LineBottom.default_color = Color(1, 0, 0)
			$Debug/LineBottomLeft.default_color = Color(0, 1, 0)
			$Debug/LineBottomRight.default_color = Color(1, 0, 0)
			if from_botleft_dist < magnet_threshold:
				must_magnet_to(last_bottom_left.global_position)
				current_dom.rotation_deg = 90
			else:
				must_magnet = false
		
				
func domino_for_panel(order):
	randomize()
	var domino = preload("res://Scenes/Domino.tscn").instance()
	domino.set_values( randi() % 6,  randi() % 6) # random numbrer from 0 to 6
	var dom_size = domino.get_item_rect().size
	domino.position = Vector2($Center.position.x - (dom_size.x/4), $Center.position.y + (dom_size.y/2) + 500)
	domino.connect("on_mouse_over_top", self, "on_mouse_over_domino")
	domino.connect("on_mouse_over_bottom", self, "on_mouse_over_domino")
	$Dominoes.add_child(domino)

func create_initial_dominoes():
	randomize()
	
	var last_bottom_value = -1
	for num in range(4):
		var domino = preload("res://Scenes/Domino.tscn").instance()
		if last_bottom_value == -1:
			domino.set_values(randi() % 6, randi() % 6) # random numbrer from 0 to 6
		else:
			domino.set_values(last_bottom_value, randi() % 6) # random numbrer from 0 to 6
		
		last_bottom_value = domino.values.bottom
			
		var dom_size = domino.get_item_rect().size
		domino.position = Vector2($Center.position.x - (dom_size.x/4), $Center.position.y + (num*dom_size.y/2))
		last_used_dom = domino
		$Dominoes.add_child( domino )
		
func must_magnet_to(pos):
	must_magnet = true
	magnet_pos = pos
	
func on_mouse_over_domino_top(is_over, top, domino):
	printt("on_mouse_over_domino", can, domino)
	if can:
		current_dom = domino
	else:
		current_dom = null
	

func _input(event):
	if current_dom != null:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.pressed:
					clicked_pos = get_local_mouse_position()
					dom_position = Vector2(current_dom.position)
					can_move = true
				else:
					can_move = false
				
		if event is InputEventMouseMotion and can_move:
			if magnet_pos!= null and magnet_pos.distance_to(get_local_mouse_position()) > 30:
				must_magnet = false
				var diff = clicked_pos - get_local_mouse_position()
				current_dom.position = dom_position - diff
			
			if must_magnet:
				print("must magnet")
				current_dom.position = magnet_pos
			else:
				print("move domino")
				var diff = clicked_pos - get_local_mouse_position()
				current_dom.position = dom_position - diff
				


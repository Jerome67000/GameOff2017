extends Node2D

var domino_scn = preload("res://Scenes/Domino.tscn")

var mouse_pressed = false
var must_magnet = false
var selected_dom
var clicked_pos = Vector2(0,0)
var magnet_pos
var is_valid_dom
var dom_scaled_size

export var magnet_threshold = 20
export var INITIAL_DOM_COUNT = 4
export var point_speed = 200

onready var anchors = {"1" : $CameraTarget/Camera2D/Panel/Pos1, "2" : $CameraTarget/Camera2D/Panel/Pos2, "3" : $CameraTarget/Camera2D/Panel/Pos3, "4" : $CameraTarget/Camera2D/Panel/Pos4}

var score = 0

func _ready():
	
	var dom_size = $Dominoes/Domino.get_node("Sprite").get_item_rect().size
	var dom_scale = $Dominoes/Domino.get_node("Sprite").scale
	dom_scaled_size = dom_size*dom_scale
	
	create_initial_dominoes()
	create_pickable_dominoes()
	connect_timer_spawn()
	
	
func _process(delta):
	$Path2D/PathFollow2D.set_offset($Path2D/PathFollow2D.get_offset() + point_speed * delta)
	check_for_magnet()
		
func set_domino_color():
	if selected_dom != null:
		if must_magnet:
			if (get_last_posed_dom().values["bottom"] == 0 or selected_dom.values["top"] == 0 or selected_dom.values["top"] == get_last_posed_dom().values["bottom"]) and not is_out_of_limit():
				selected_dom.set_good_color()
			else:
				selected_dom.set_wrong_color()
		else:
			if selected_dom.position.y > 145:
				selected_dom.set_wrong_color()
			else:
				selected_dom.set_clear_color()
				

func is_out_of_limit():
	if must_magnet:
		var bot = selected_dom.get_node("Positions/Bottom")
		if bot.global_position.x < 0:
			return true
		if bot.global_position.x > $Background.region_rect.size.x:
			return true
		if bot.global_position.y < 0:
			return true
		if bot.global_position.y > $Background.region_rect.size.y:
			return true
		if selected_dom.over_placed:
			return true
	else:
		return false

func _on_mouse_over_domino(is_over, domino):
	if not mouse_pressed:
		#printt("_on_mouse_over_domino", "is_over: " + str(is_over), domino.unique_id)
		if is_over:
			selected_dom = domino
		else:
			selected_dom = null
	
func _on_dom_placed(domino):
	domino.set_clear_color()
	domino.reparent_to($Dominoes, magnet_pos)
	$CameraTarget.position = magnet_pos + Vector2(0, 180)
	add_point_to_path(domino)
	selected_dom = null
	score += 1
	$CameraTarget/Camera2D/Score/LabelScore.text = str(score)
	
	for point in range(0, $Path2D.curve.get_point_count()):
		printt("point: ", $Path2D.curve.get_point_position(point))

func add_point_to_path(domino):
#	var last_point = $Path2D.curve.get_point_position($Path2D.curve.get_point_count()-1)
#
#	if domino.rotation_deg == 90:
#		var to_add = Vector2(dom_scaled_size.y, 0)
#		last_point -= to_add
#	elif domino.rotation_deg == -90:
#		var to_add = Vector2(dom_scaled_size.y, 0)
#		last_point += to_add
#	elif domino.rotation_deg == 180 or domino.rotation_deg == -180:
#		var to_add = Vector2(0, dom_scaled_size.y)
#		last_point -= to_add
#	else:
#		var to_add = Vector2(0, dom_scaled_size.y)
#		last_point += to_add
		
	$Path2D.curve.add_point(domino.get_node("Positions/BottomCenter").global_position)
	
	
func connect_timer_spawn():
	$CameraTarget/Camera2D/Panel/Pos1.connect("_spawn_new_dom", self, "_on_spawn_new_dom")
	$CameraTarget/Camera2D/Panel/Pos2.connect("_spawn_new_dom", self, "_on_spawn_new_dom")
	$CameraTarget/Camera2D/Panel/Pos3.connect("_spawn_new_dom", self, "_on_spawn_new_dom")
	$CameraTarget/Camera2D/Panel/Pos4.connect("_spawn_new_dom", self, "_on_spawn_new_dom")

func _on_spawn_new_dom(anchor_pos):
	add_new_domino(anchor_pos)
	
func get_last_posed_dom():
	return $Dominoes.get_child($Dominoes.get_child_count()-1)

#####################
#### INPUTS
#####################
func _input(event):
	if selected_dom != null:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				manage_mouse_click(event.pressed)
				
		if event is InputEventMouseMotion and mouse_pressed:
			manage_mouse_motion()

				
func manage_mouse_click(clicked):
	if clicked:
		clicked_pos = get_global_mouse_position()
		mouse_pressed = true
	else:
		mouse_pressed = false
		if must_magnet and selected_dom.valid_color():
			selected_dom.place_and_lock()
		elif must_magnet == false and selected_dom.position.y > 145:
			selected_dom.droped()
			selected_dom = null
		else:
			selected_dom.reset_pos_and_rot()
		
func manage_mouse_motion():
	if magnet_pos != null and magnet_pos.distance_to(get_global_mouse_position()) > 30:
		must_magnet = false
		if selected_dom != null:
			selected_dom.get_node("Sprite").rotation_deg = 0
			selected_dom.get_node("PickableZone").rotation_deg = 0
	
	if must_magnet:
		selected_dom.global_position = magnet_pos
	else:
		var diff = clicked_pos - get_global_mouse_position()
		selected_dom.position = -diff
		
	set_domino_color()
	
func magnet_to(pos):
	must_magnet = true
	magnet_pos = pos

#####################
#### INIT SCENE
#####################
func create_initial_dominoes():
	randomize()
	
	var last_bottom_value = randi() % 6
	for num in range(4):
		var domino = domino_scn.instance()
		
		# if last value is blank, dont use it for next value
		if last_bottom_value == 0:
			last_bottom_value = randi() % 6
			
		domino.set_values(last_bottom_value, randi() % 6) # random numbrer from 0 to 6
		last_bottom_value = domino.values.bottom
		
		domino.position = Vector2($Center.position.x, $Center.position.y + (num*dom_scaled_size.y))
		domino.set_pickable(false)
		$Dominoes.add_child(domino)
		$Path2D.curve.add_point(domino.get_node("Positions/BottomCenter").global_position)
		
func create_pickable_dominoes():
	for num in range(INITIAL_DOM_COUNT):
		add_new_domino(num)
		
func add_new_domino(anchor):
	randomize()
	var domino = domino_scn.instance()
	var anchor_num = str(anchor+1)
	domino.set_values(randi() % 6,  randi() % 6) # random numbrer from 0 to 6
	domino.bind_panel_anchor(anchors[anchor_num])

	domino.connect("_on_dom_can_move", self, "_on_mouse_over_domino")
	domino.connect("_on_dom_placed", self, "_on_dom_placed")
	anchors[anchor_num].add_child(domino)

#####################
#### DEBUG
#####################
func check_for_magnet():
	if selected_dom != null:
		var curr_top = selected_dom.get_node("Positions/Top")
		var last_bottom = get_last_posed_dom().get_node("Positions/Bottom")
		var last_bottom_left = get_last_posed_dom().get_node("Positions/BottomLeft")
		var last_bottom_right = get_last_posed_dom().get_node("Positions/BottomRight")
			
		
		var from_bot_dist = curr_top.global_position.distance_to(last_bottom.global_position)
		var from_botleft_dist = curr_top.global_position.distance_to(last_bottom_left.global_position)
		var from_botright_dist = curr_top.global_position.distance_to(last_bottom_right.global_position)
			
		if from_bot_dist < from_botleft_dist and from_bot_dist < from_botright_dist:
			if from_bot_dist < magnet_threshold:
				magnet_to(last_bottom.global_position)
				selected_dom.rotation_deg = 0 + get_last_posed_dom().rotation_deg
			else:
				must_magnet = false
	
		if from_botright_dist < from_bot_dist and from_botright_dist < from_botleft_dist:
			if from_botright_dist < magnet_threshold:
				magnet_to(last_bottom_right.global_position)
				selected_dom.rotation_deg = -90 + get_last_posed_dom().rotation_deg
			else:
				must_magnet = false
				
		if from_botleft_dist < from_bot_dist and from_botleft_dist < from_botright_dist:
			if from_botleft_dist < magnet_threshold:
				magnet_to(last_bottom_left.global_position)
#				selected_dom.rot_min_90() TODO
				selected_dom.rotation_deg = 90 + get_last_posed_dom().rotation_deg
			else:
				must_magnet = false

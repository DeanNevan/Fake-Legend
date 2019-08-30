extends Node

var use_probability = 0
var life_cost
var stamina_cost
var magic_cost
var level
var myself

var is_launching := false
var player_control_event

var reset_timer := true
var max_launch_time = 2
onready var timer = Timer.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	myself = get_parent().get_parent()
	is_launching = false
	add_child(timer)
	timer.one_shot = true

func _physics_process(delta):
	time_inspect()

func time_inspect():
	if is_launching:
		print(timer.time_left)
		if reset_timer:
			print("start timer")
			timer.wait_time = max_launch_time
			timer.start()
			reset_timer = false
		if timer.time_left == 0:
			is_launching = false
			myself.is_moving_self_with_ability = false
			myself.is_moving_weapon_with_ability = false
			reset_timer = true
			print("launch too much time")
			return
	else:
		reset_timer = true

func judge_whether_launch():
	if randf() <= use_probability and !is_launching:
		return true
	else:
		return false
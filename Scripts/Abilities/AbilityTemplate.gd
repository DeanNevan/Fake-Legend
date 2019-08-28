extends Node

var use_probability = 0
var life_cost
var stamina_cost
var magic_cost
var level
var myself

var is_launching

var player_control_event

# Called when the node enters the scene tree for the first time.
func _ready():
	myself = get_parent().get_parent()
	is_launching = false

func _judge_whether_launch():
	if randf() <= use_probability and !is_launching:
		return true
	else:
		return false
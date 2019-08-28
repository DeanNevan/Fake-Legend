extends "res://Scripts/Abilities/AbilityTemplate.gd"

var strike_distance = 30
var direction = Vector2()
var speed = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	preload("res://Scripts/Abilities/AbilityTemplate.gd")
	life_cost = 0
	magic_cost = 0
	stamina_cost = 5
	level = 1
	
	speed = myself.max_speed * 2

func _physics_process(delta):
	if is_launching:
		myself.linear_velocity = direction * speed

func launch():
	if !myself.has_weapon:
		use_probability = 0.016
	else:
		use_probability = 0.004
	if !._judge_whether_launch():
		return
	print("strike!!!")
	
	if myself.tag == "enemy":
		direction = myself.vector_self_to_player.normalized()
	if myself.tag == "player":
		direction = myself.vector_player_to_mouse.normalized()
	is_launching = true
	myself.is_moving_self_with_ability = true
	myself.contact_monitor = true
	speed = - 10
	yield(get_tree().create_timer(0.4), "timeout")
	speed = 0
	myself.linear_velocity = Vector2()
	yield(get_tree().create_timer(0.3), "timeout")
	speed = myself.max_speed * 2
	yield(get_tree().create_timer(0.4), "timeout")
	speed = 0
	myself.linear_velocity = Vector2()
	yield(get_tree().create_timer(0.2), "timeout")
	speed = - myself.max_speed * 2
	yield(get_tree().create_timer(0.3), "timeout")
	speed = 0
	myself.linear_velocity = Vector2()
	is_launching = false
	myself.is_moving_self_with_ability = false
	myself.contact_monitor = false
	print("stop stike!!!")
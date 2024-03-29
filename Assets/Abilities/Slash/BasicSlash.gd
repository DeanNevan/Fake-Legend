extends "res://Scripts/Abilities/AbilityTemplate.gd"
signal approach_target_position
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var is_approached := false
var target_direction := Vector2(1, 0)
var target_vector := Vector2(1, 0)
var speed = 0

var should_judge := false

var vector_self_to_target_position := Vector2()
# Called when the node enters the scene tree for the first time.
func _ready():
	use_probability = 0.016
	need_weapon = true
	need_self = true
	
	life_cost = 0
	magic_cost = 0
	stamina_cost = 0
	level = 1
	max_launch_time = 2.5
	
	player_control_event = KEY_X
	launch_ai_state = ["combating"]
	require_weapon_type = ["melee"]
	require_body_capability = ["moveable", "can_control_weapon", "can_use_ability"]

func _physics_process(delta):
	judge_whether_approached_target_position()
	_update()
	launch()

func judge_whether_approached_target_position():
	if self.is_launching:
		#print((myself.weapon.global_position - (myself.global_position + target_vector)).length())
		if (myself.weapon.global_position - (myself.global_position + target_vector)).length() < 10 and should_judge:
			emit_signal("approach_target_position")

func _update():
	if self.is_launching:
		myself.is_controlling_self_with_ability = true
		myself.is_controlling_weapon_with_ability = true
		myself.weapon.wave_weapon((target_vector - (myself.weapon.global_position - myself.global_position)).normalized(), speed)
		myself.rotate_weapon((myself.strength - myself.weapon.weight) * 0.7, (myself.weapon.global_position - myself.global_position).normalized(), get_physics_process_delta_time())
		myself.ai_move(vector_self_to_target_position.normalized(), myself.max_speed / 3.0)

func launch():
	if !.judge_whether_launch():
		return
	var del = clamp(myself.strength - myself.weapon.weight, 3, 20)
	if myself.tag == "player":
		vector_self_to_target_position = myself.vector_self_to_mouse
	if myself.tag == "enemy":
		vector_self_to_target_position = myself.vector_self_to_player
	#print("start!!")
	var rotate_degree = rand_range(- PI / 2.5, PI / 2.5)
	while abs(rotate_degree) < 0.5:
		rotate_degree = rand_range(- PI / 2.5, PI / 2.5)
	var target_angle = vector_self_to_target_position.angle() + rotate_degree
	target_direction = Vector2(cos(target_angle), sin(target_angle))
	target_vector = target_direction * myself.arm_length
	speed = del * 1.2 + (target_vector - (myself.weapon.global_position - myself.global_position)).length() * 1
	
	is_launching = true
	should_judge = true
	yield(self, "approach_target_position")
	should_judge = false
	yield(get_tree().create_timer(0.3), "timeout")
	
	#print("wave!!")
	target_angle = vector_self_to_target_position.angle() - rotate_degree
	target_direction = Vector2(cos(target_angle), sin(target_angle))
	target_vector = target_direction * myself.arm_length
	speed = del * 1.2 + (target_vector - (myself.weapon.global_position - myself.global_position)).length() * 1.2
	should_judge = true
	yield(self, "approach_target_position")
	should_judge = false
	yield(get_tree().create_timer(0.3), "timeout")
	
	#print("end!!")
	is_launching = false
	myself.is_controlling_self_with_ability = false
	myself.is_controlling_weapon_with_ability = false
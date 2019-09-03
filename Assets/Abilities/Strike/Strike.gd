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
	
	player_control_event = KEY_Z
	launch_ai_state = ["combating"]
	require_weapon_type = []
	require_body_capability = ["moveable", "can_use_ability"]
	need_self = true
	
	myself.connect("body_entered", self, "_on_body_entered")

func _physics_process(delta):
	_update()

func _update():
	if is_launching:
		myself.is_controlling_self_with_ability = true
		myself.linear_velocity = direction * speed

func _on_body_entered(body):
	if body.tag != myself.tag:
		if body.has_method("get_damage"):
			var damage = (body.linear_speed - myself.linear_speed).length() / 3.0 * clamp((myself.strength - myself.weight) / 2.0 , 3, 8)
			body.get_damage(damage, true, myself.global_position)
			#print(damage)

func launch():
	if myself.tag == "enemy":
		if myself.distance_self_to_player > 100:
			return
	if !myself.has_weapon:
		use_probability = 0.016
	elif myself.weapon.type == "melee":
		use_probability = 0.004
	else:
		use_probability = 0.001
	if !.judge_whether_launch():
		return
	
	if myself.tag == "enemy":
		direction = myself.vector_self_to_player.normalized()
	if myself.tag == "player":
		direction = myself.vector_self_to_mouse.normalized()
	is_launching = true
	
	myself.contacts_reported = 6
	myself.contact_monitor = true
	#print("strike!!!")
	
	speed = - 10
	yield(get_tree().create_timer(0.4), "timeout")
	speed = 0
	myself.linear_velocity = Vector2()
	yield(get_tree().create_timer(0.3), "timeout")
	speed = myself.max_speed * 2.5
	yield(get_tree().create_timer(0.4), "timeout")
	speed = 0
	myself.linear_velocity = Vector2()
	yield(get_tree().create_timer(0.2), "timeout")
	speed = - myself.max_speed * 2
	yield(get_tree().create_timer(0.35), "timeout")
	speed = 0
	myself.linear_velocity = Vector2()
	is_launching = false
	myself.is_controlling_self_with_ability = false
	myself.contact_monitor = false
	myself.contacts_reported = 0
	#print("stop stike!!!")
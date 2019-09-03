extends Node

var use_probability = 0
var life_cost
var stamina_cost
var magic_cost
var level
var myself

var need_weapon = false
var need_self = false

var is_launching := false
var launch_ai_state := []
var player_control_event = KEY_BACKSPACE
var require_weapon_type = []
var require_body_capability = []

var reset_timer := true
var max_launch_time = 2
var max_bear_damage
var life_when_start_ability
onready var timer = Timer.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	myself = get_parent().get_parent()
	max_bear_damage = myself.max_life / 4.0
	is_launching = false
	add_child(timer)
	timer.one_shot = true

func _physics_process(delta):
	_time_inspector()
	_take_damage_inspector()
	_body_capability_inspector()

func break_ability():
	is_launching = false
	myself.is_controlling_self_with_ability = false
	myself.is_controlling_weapon_with_ability = false
	reset_timer = true

func _take_damage_inspector():
	if is_launching:
		if myself.life - life_when_start_ability > max_bear_damage:
			break_ability()

func _body_capability_inspector():
	if is_launching:
		for i in require_body_capability:
			if !myself.body_capability[i]:
				break_ability()

func _time_inspector():
	if is_launching:
		#print(timer.time_left)
		if reset_timer:
			#print("start timer")
			timer.wait_time = max_launch_time
			timer.start()
			reset_timer = false
		if timer.time_left == 0:
			break_ability()
			#print("launch too much time")
			return
	else:
		reset_timer = true

func judge_whether_launch():
	life_when_start_ability = myself.life
	
	if need_self:
		if myself.has_weapon:
			if myself.weapon.is_controlling_master_with_ability:
				return false
		if myself.is_controlling_self_with_ability:
			return false
	if need_weapon and myself.has_weapon:
		if myself.weapon.is_controlling_self_with_ability or myself.is_controlling_weapon_with_ability:
			return false
	
	if require_weapon_type.size() != 0:
		var is_match_require_weapon = false
		if myself.has_weapon:
			for i in require_weapon_type:
				if i == myself.weapon.type:
					is_match_require_weapon = true
		if !is_match_require_weapon:
			return false
	
	if require_body_capability.size() != 0:
		#var is_match_body_capability = false
		for i in require_body_capability:
			if !myself.body_capability[i]:
				return false
	
	if myself.tag == "enemy":
		var is_ai_state_match = false
		if launch_ai_state.size() > 0:
			for i in launch_ai_state:
				if i == myself.ai_state:
					is_ai_state_match = true
		elif launch_ai_state.size() == 0:
			is_ai_state_match = true
		if randf() <= use_probability and !is_launching and is_ai_state_match:
			return true
		else:
			return false
	if myself.tag == "player":
		if Input.is_key_pressed(player_control_event):
			return true
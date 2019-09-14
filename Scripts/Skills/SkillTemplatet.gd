extends Node

signal init

var life_cost
var stamina_cost
var magic_cost
var level
var myself

var init_ok := false
var cd_time
var can_use := true

var is_launching := false
var player_control_event = KEY_BACKSPACE

var reset_timer := true
var max_launch_time = 5
var max_bear_damage
#var life_when_start_skill
#var should_update_life_when_start_skill = true
onready var timer = Timer.new()

func _ready():
	myself = get_parent().get_parent()
	myself.connect("init", self, "_skill_init")

func _process(delta):
	_time_inspector()

func break_skill():
	is_launching = false
	reset_timer = true

func update_myself_points():
	if myself.tag == "player_weapon" or myself.tag == "enemy_weapon":
		myself.weapon_master.life -= life_cost
		myself.weapon_master.stamina -= stamina_cost
		#myself.weapon_master.magic -= magic_cost

func _skill_init():
	if myself.tag == "player" or myself.tag == "enemy":
		max_bear_damage = myself.max_bear_damage
	elif myself.tag == "player_weapon" or myself.tag == "enemy_weapon":
		max_bear_damage = myself.weapon_master.max_bear_damage
	is_launching = false
	add_child(timer)
	timer.one_shot = true
	emit_signal("init")

func _time_inspector():
	if is_launching:
		#print(timer.time_left)
		if reset_timer:
			#print("start timer")
			timer.wait_time = max_launch_time
			timer.start()
			reset_timer = false
		if timer.time_left == 0:
			break_skill()
			#print("launch too much time")
			return
	else:
		reset_timer = true
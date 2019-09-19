extends "res://Scripts/Skills/SkillTemplatet.gd"

var special_arrow

var target_vector
var is_arrow_flying := false
var is_pulling := false
var should_release := false
var arrow_res : String
var is_releasing := false
var delay_one_frame = false



func _ready():
	
	cd_time = 5
	#myself.arrow.connect("tree_exiting", self, "_stop")
	self.connect("init", self, "_skill_init")
	life_cost = 10
	stamina_cost = 10
	magic_cost = 10
	player_control_event = KEY_C

func _process(delta):
	#print(target_vector)
	if !init_ok:
		return
	#print(myself.type)
	if myself.tag == "player_weapon":
		if Input.is_key_pressed(player_control_event) and !is_launching and can_use:
			_start()
	#print(special_arrow.get_instance_id())
	if is_launching:
		
		if (special_arrow.global_position - myself.global_position).length() >= 400:
			special_arrow._free()
		
		self.global_position = special_arrow.global_position + Vector2(cos(special_arrow.global_rotation), sin(special_arrow.global_rotation)).normalized() * 5
		$AnimatedSprite.global_rotation = special_arrow.global_rotation
		$Particles2D.global_rotation = (- (Vector2(cos(special_arrow.global_rotation), sin(special_arrow.global_rotation)))).angle()
		$Particles2D.process_material.initial_velocity = special_arrow.linear_velocity.length() / 8
		

func _start():
	can_use = false
	var ang = myself.global_rotation
	target_vector = Vector2(cos(ang), sin(ang))
	myself.is_controlling_self_with_ability = true
	is_launching = true
	update_myself_points()
	special_arrow = load(myself.arrow_res).instance()
	special_arrow.weapon = myself
	special_arrow.can_pierce = true
	special_arrow.linear_damp = 0
	special_arrow.angular_damp = 0
	special_arrow.connect("tree_exiting", self, "_stop")
	get_node("/root/Main").add_child(special_arrow)
	$AnimatedSprite.visible = true
	self.global_position = special_arrow.global_position + Vector2(cos(special_arrow.global_rotation), sin(special_arrow.global_rotation)).normalized() * 5
	$AnimatedSprite.global_rotation = special_arrow.global_rotation
	
	yield(get_tree().create_timer(1), "timeout")
	$Particles2D.process_material.angle = special_arrow.global_rotation_degrees
	$Particles2D.emitting = true
	_release()

func _release():
	special_arrow.start_fly(target_vector.normalized() * myself.strength * 3)

func _skill_init():
	init_ok = false
	#print(myself.type)
	#print(myself.ranged_weapon_type)
	if myself.type == "ranged":
		if myself.ranged_weapon_type == "bow":
			special_arrow = myself.arrow
			#print(special_arrow.name)
			#special_arrow.connect("tree_exiting", self, "_stop")
			special_arrow.weapon = myself
			$AnimatedSprite.visible = false
			$AnimatedSprite.play("default")
			$Particles2D.emitting = false
			$Particles2D.amount = 100
	init_ok = true
	

func _stop():
	print("stop!!!!!!!!")
	is_launching = false
	myself.is_controlling_self_with_ability = false
	$AnimatedSprite.visible = false
	$Particles2D.emitting = false
	yield(get_tree().create_timer(cd_time), "timeout")
	can_use = true

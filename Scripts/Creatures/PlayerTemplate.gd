extends "res://Scripts/Creatures/CreatureTemplate.gd"

var vector_player_to_weapon = Vector2()
var vector_player_to_mouse = Vector2()
var vector_weapon_to_mouse = Vector2()

var control_direction := Vector2()#键盘按键wasd所指方向

var is_controlling := true
var is_control_pressed := false



func _ready():
	preload("res://Scripts/Creatures/CreatureTemplate.gd")
	_player_init()
	_player_weapon_init()
	#print("total weight is", total_weight)

func _physics_process(delta):
	_update_vector_of_player_mouse_weapon()
	judge_towards(get_global_mouse_position())#判断朝向
	update_animation()#更新动画
	update_ghost()
	_judge_control_direcition()#判断wasd所控制的方向
	if Input.is_action_just_pressed("control_mouse_right_click"):
		self.strength = self.strength + 1
		print("plus strength!",strength)
	if body_capability["controllable"] == true: 
		_smooth_control_move()
	if Input.is_key_pressed(KEY_SHIFT):
		dodge(control_direction.normalized())
	#print(wave_weapon_vector)
	#print(wave_weapon_speed)
	if has_weapon:
		rotate_weapon((self.strength - weapon.weight) * 0.7, vector_weapon_to_mouse.normalized(), delta)
	if has_weapon and weapon.type == "melee":
		wave_weapon_vector = get_wave_weapon_vector()
		wave_weapon_speed = get_wave_weapon_speed()
		wave_weapon_direction = wave_weapon_vector.normalized()
		wave_weapon(wave_weapon_direction, wave_weapon_speed)

func _input(event):
	pass

func _basic_control_move(speed):#基础 控制人物移动
	velocity = Vector2()
	if Input.is_action_pressed("control_right"):
		velocity.x += 1
		is_control_pressed = true
	if Input.is_action_pressed("control_left"):
		velocity.x -= 1
		is_control_pressed = true
	if Input.is_action_pressed("control_down"):
		velocity.y += 1
		is_control_pressed = true
	if Input.is_action_pressed("control_up"):
		velocity.y -= 1
		is_control_pressed = true
	velocity = velocity.normalized() * speed
	self.linear_velocity = velocity
	is_control_pressed = false

func _smooth_control_move():#平滑 控制人物移动
	var velocity_damp_direction = Vector2()
	var velocity_damp_length = 0
	if Input.is_action_pressed("control_right"):
		velocity.x += clamp((strength - total_weight) / 1.5, 2, 15)
		is_control_pressed = true
	if Input.is_action_pressed("control_left"):
		velocity.x -= clamp((strength - total_weight) / 1.5, 2, 15)
		is_control_pressed = true
	if Input.is_action_pressed("control_down"):
		velocity.y += clamp((strength - total_weight) / 1.5, 2.5, 15)
		is_control_pressed = true
	if Input.is_action_pressed("control_up"):
		velocity.y -= clamp((strength - total_weight) / 1.5, 2.5, 15)
		is_control_pressed = true
	if !is_control_pressed:#未按下control按键时 减速
		velocity_damp_direction = (Vector2() - velocity).normalized()
		velocity_damp_length = clamp((strength - total_weight) / 1.5, 2.5, 15)
		velocity += velocity_damp_direction * velocity_damp_length
		if velocity.length() <= 15:
			velocity = Vector2()
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	else:
		velocity = velocity.normalized() * velocity.length()
	self.linear_velocity = velocity
	is_control_pressed = false

func _update_vector_of_player_mouse_weapon():
	vector_player_to_mouse = get_global_mouse_position() - self.get_global_position()
	if has_weapon:
		vector_weapon_to_mouse = get_global_mouse_position() - weapon.get_global_position()
		vector_player_to_weapon = weapon.get_global_position() - self.get_global_position()

func _judge_control_direcition():#判断键盘wasd所控制的方向
	if !Input.is_action_pressed("control_right") and !Input.is_action_pressed("control_left"):
		control_direction.x = 0
	if !Input.is_action_pressed("control_down") and !Input.is_action_pressed("control_up"):
		control_direction.y = 0
	if Input.is_action_pressed("control_right"):
		control_direction.x = 1
	if Input.is_action_pressed("control_left"):
		control_direction.x = -1
	if Input.is_action_pressed("control_down"):
		control_direction.y = 1
	if Input.is_action_pressed("control_up"):
		control_direction.y = -1

func get_wave_weapon_vector():
	if Input.is_action_pressed("control_mouse_left_click"):
		var target_postion = Vector2()
		#print("weapon length",weapon_length)
		if vector_player_to_mouse.length() <= arm_length:
			target_postion = get_global_mouse_position()
		else:
			target_postion = self.get_global_position() + ((vector_player_to_mouse).normalized() * arm_length)
		#print("target position is",target_postion)
		var wave_weapon_vector = target_postion - weapon.get_global_position()
		#print("towards",wave_weapon_towards)
		if weapon.position.length() > arm_length:
			return - weapon.position * 5
		else:
			return wave_weapon_vector
	elif weapon.position.length() >= 3:
		var return_vector = - weapon.position * 5
		return return_vector
	else:
		weapon.position = Vector2()
		return Vector2()

func get_wave_weapon_speed():
	#print("strength",strength)
	#print("weight",weight)
	var del = clamp(strength - weapon.weight, 0, 30)
	var speed = (strength - weapon.weight) * 1.2 + wave_weapon_vector.length() * 0.5
	#print("speed is",speed)
	return speed

func _player_init():
	self.add_to_group("player")
	i_am_player()
	tag = "player"
	life = max_life

func _player_weapon_init():
	if weaponScene != null:
		has_weapon = true
		weapon = weaponScene.instance()
		self.add_child(weapon)
		weapon.tag = "player_weapon"
		weapon.add_to_group("player_weapon")
		weapon.i_am_player_weapon()
		#weapon.linear_damp = clamp(self.strength - weapon.weight + 2, 12, 18)
		#weapon.angular_damp = clamp(self.strength  - weapon.weight - 1, 3, 10)
		total_weight = self.weight + weapon.weight#人物与武器总重
		self.attack_distance = self.arm_length + weapon.length
	else:
		has_weapon = false
		total_weight = self.weight
		self.attack_distance = self.arm_length
extends "res://Scripts/Creatures/CreatureTemplate.gd"

var vector_player_to_weapon = Vector2()
var vector_self_to_mouse = Vector2()
var vector_weapon_to_mouse = Vector2()

var control_direction := Vector2()#键盘按键wasd所指方向

var is_controlling := true
var is_control_pressed := false
var is_dodging := false



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
	if body_capability["moveable"] == true: 
		_smooth_control_move()
	if Input.is_key_pressed(KEY_SHIFT):
		dodge(control_direction.normalized())
	#if is_dodging:
		#weapon.position = weapon.position
	#print(wave_weapon_vector)
	#print(wave_weapon_speed)
	if has_weapon and weapon.type == "melee":
		if Input.is_action_pressed("control_mouse_left_click"):
			rotate_weapon((self.strength - weapon.weight) * 0.7, vector_weapon_to_mouse.normalized(), delta)
		wave_weapon_vector = get_wave_weapon_vector()
		wave_weapon_speed = get_wave_weapon_speed()
		wave_weapon_direction = wave_weapon_vector.normalized()
		wave_weapon(wave_weapon_direction, wave_weapon_speed)
		if weapon.position.length() > arm_length * 1.5:
			weapon.is_stuck = true
		else:
			weapon.is_stuck = false
	#print(self.linear_velocity)
	#print(get_viewport_rect().size)

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
		velocity.x += clamp((strength - total_weight) / 1, 3, 15)
		is_control_pressed = true
	if Input.is_action_pressed("control_left"):
		velocity.x -= clamp((strength - total_weight) / 1, 3, 15)
		is_control_pressed = true
	if Input.is_action_pressed("control_down"):
		velocity.y += clamp((strength - total_weight) / 1, 3, 15)
		is_control_pressed = true
	if Input.is_action_pressed("control_up"):
		velocity.y -= clamp((strength - total_weight) / 1, 3, 15)
		is_control_pressed = true
	if !is_control_pressed:#未按下control按键时 减速
		velocity_damp_direction = (Vector2() - velocity).normalized()
		velocity_damp_length = clamp((strength - total_weight) / 1, 2.5, 15)
		velocity += velocity_damp_direction * velocity_damp_length
		if velocity.length() <= 15:
			velocity = Vector2()
	is_control_pressed = false
	if self.has_weapon:#如果武器卡住了，玩家只能向着减少与武器距离的方向移动
		if self.weapon.is_stuck:
			if ((self.global_position + velocity.normalized()) - weapon.global_position).length() > vector_player_to_weapon.length():
				velocity = Vector2()
				self.linear_velocity = velocity
				return
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	else:
		velocity = velocity.normalized() * velocity.length()
	self.linear_velocity = velocity

func _update_vector_of_player_mouse_weapon():
	vector_self_to_mouse = get_global_mouse_position() - self.get_global_position()
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
		var wave_length = clamp(vector_self_to_mouse.length(), 0, arm_length)
		var target_postion = self.global_position + (vector_self_to_mouse).normalized() * wave_length
		var wave_weapon_vector = target_postion - weapon.get_global_position()
		if wave_weapon_vector.length() <= 1.5:
			return Vector2()
		#print(vector_self_to_mouse)
		#print(wave_length)
		#print(target_postion)
		#print(wave_weapon_vector)
		return wave_weapon_vector
	elif weapon.position.length() >= 3:
		var return_vector = - weapon.position * 2
		return return_vector
	else:
		weapon.position = Vector2()
		return Vector2()

func get_wave_weapon_speed():
	#print("strength",strength)
	#print("weight",weight)
	var del = clamp(strength - weapon.weight, 3, 20)
	var speed = del * 1.2 + wave_weapon_vector.length() * 1.2
	#print("speed is",speed)
	return speed

func dodge(direction):#冲刺
	if body_capability["can_dodge"] == true and body_capability["moveable"] == true:
		if !has_weapon:
			pass
		elif weapon.is_stuck:
			return
		body_capability["moveable"] = false
		is_dodging = true
		var dodge_velocity_bonus = direction * (max_speed / 2) * clamp(self.strength / 2.0, 1, 20)
		#print("dodging")
		if has_weapon:
			weapon.linear_velocity = dodge_velocity_bonus * 2.5
		self.linear_velocity = dodge_velocity_bonus
		ghost.restart()
		ghost.visible = true
		yield(get_tree().create_timer(dodge_time), "timeout")
		self.velocity = Vector2()
		ghost.visible = is_ghost_visible
		#print("finish dodge")
		body_capability["can_dodge"] = false
		body_capability["moveable"] = true
		is_dodging = false
		DodgeCooldownTimer.start()

func _player_init():
	self.add_to_group("player")
	i_am_player()
	self.contact_monitor = true
	tag = "player"
	life = max_life
	
	#冲刺&闪避方法相关#
	DodgeCooldownTimer = Timer.new()
	add_child(DodgeCooldownTimer)
	DodgeCooldownTimer.one_shot = true
	DodgeCooldownTimer.wait_time = 1.5
	DodgeCooldownTimer.connect("timeout", self, "_on_DodgeCooldownTimer_timeout")

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
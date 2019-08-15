extends "res://Scripts/Creatures/CreatureTemplate.gd"

signal hit

var vector_player_to_weapon = Vector2()
var vector_player_to_mouse = Vector2()
var vector_weapon_to_mouse = Vector2()

var control_direction := Vector2()#键盘按键wasd所指方向

var is_controlling := true
var is_control_pressed := false

func _ready():
	player_init()
	player_weapon_init()
	total_weight = self.weight + weapon.weight#人物与武器总重
	#print("total weight is", total_weight)

func _physics_process(delta):
	judge_control_direcition()#判断wasd所控制的方向

	if Input.is_action_just_pressed("control_mouse_right_click"):
		self.strength = self.strength + 1
		print("plus strength!",strength)
	if is_ani:#如果是AnimatedSprite
		judge_towards()#判断朝向
		turn_to_towards()#转向朝向
	if self.can_control_self: 
		smooth_control_move(max_speed, total_weight)
	if Input.is_key_pressed(KEY_SHIFT):
		dodge(control_direction.normalized())
	
	vector_player_to_mouse = get_global_mouse_position() - self.get_global_position()
	vector_weapon_to_mouse = get_global_mouse_position() - weapon.get_global_position()
	vector_player_to_weapon = weapon.get_global_position() - self.get_global_position()
	
	if weapon.is_controllable == true:
		rotate_weapon((self.strength - weapon.weight) * 0.7,delta)
	if weapon.type == "melee":
		wave_weapon()

func basic_control_move(speed):#基础 控制人物移动
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

func smooth_control_move(max_speed, total_weight):#平滑 控制人物移动
	var velocity_damp_direction = Vector2()
	var velocity_damp_length = 0
	if Input.is_action_pressed("control_right"):
		velocity.x += clamp(strength - total_weight / 2, 3, 15)
		is_control_pressed = true
	if Input.is_action_pressed("control_left"):
		velocity.x -= clamp(strength - total_weight / 2, 3, 15)
		is_control_pressed = true
	if Input.is_action_pressed("control_down"):
		velocity.y += clamp(strength - total_weight / 2, 3, 15)
		is_control_pressed = true
	if Input.is_action_pressed("control_up"):
		velocity.y -= clamp(strength - total_weight / 2, 3, 15)
		is_control_pressed = true
	if !is_control_pressed:#未按下control按键时 减速
		velocity_damp_direction = (Vector2() - velocity).normalized()
		velocity_damp_length = clamp(strength - total_weight / 2, 3, 15)
		velocity += velocity_damp_direction * velocity_damp_length
		if velocity.length() <= 15:
			velocity = Vector2()
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	else:
		velocity = velocity.normalized() * velocity.length()
	self.linear_velocity = velocity
	is_control_pressed = false

func judge_control_direcition():#判断键盘wasd所控制的方向
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

func judge_towards():#判断人物朝向
	if is_ani:
		var vec_x = vector_player_to_mouse.x
		var vec_y = vector_player_to_mouse.y
		if vec_x == 0:
			return
		if (vec_y / vec_x) >= -1 and (vec_y / vec_x) <= 1:
			if vec_x >= 0:
				towards = "right"
			else:
				towards = "left"
		else:
			if vec_y > 0:
				towards = "down"
			else:
				towards = "up"

func turn_to_towards():#转向朝向
	if is_ani:
		if towards == "right":
			ani.flip_h = false
			ani.animation = "horizon"
		if towards == "left":
			ani.flip_h = true
			ani.animation = "horizon"
		if towards == "up":
			ani.animation = "up"
		if towards == "down":
			ani.animation = "down"

func get_wave_weapon_vector(weapon_length):
	if Input.is_action_pressed("control_mouse_left_click"):
		var target_postion = Vector2()
		#print("weapon length",weapon_length)
		if vector_player_to_mouse.length() <= weapon_length + arm_length:
			target_postion = get_global_mouse_position()
		else:
			target_postion = self.get_global_position() + ((vector_player_to_mouse).normalized() * weapon_length)
		#print("target position is",target_postion)
		var wave_weapon_vector = target_postion - weapon.get_global_position()
		#print("towards",wave_weapon_towards)
		if (target_postion - weapon.get_global_position()).length() <= (weapon_length + arm_length) / 2.0:
			return Vector2()
		else:
			return wave_weapon_vector
	elif weapon.position.length() >= 10:
		var return_vector = -weapon.position*5
		return return_vector
	else:
		weapon.position = Vector2()
		return Vector2()

func get_wave_weapon_speed(strength,weight,wave_weapon_vector,weapon_length):
	#print("strength",strength)
	#print("weight",weight)
	var speed = (strength - weight) * 1.5 + wave_weapon_vector.length() * 1.2
	#print("speed is",speed)
	return speed

func rotate_weapon(speed,delta):
	var target_direction = (vector_weapon_to_mouse).normalized()
	var present_direction = Vector2(1, 0).rotated(weapon.global_rotation)
	weapon.global_rotation = present_direction.linear_interpolate(target_direction, speed * delta).angle()

func wave_weapon():
	if weapon.position.length() <= 2:
		weapon_speed_bonus = clamp((strength - weapon.weight) / 4, 1.5, 8.0)
	#print(weapon_speed_bonus)
	weapon_speed_bonus = weapon_speed_bonus * 0.9
	if weapon_speed_bonus <=1:
		weapon_speed_bonus = 1
		
	wave_weapon_vector = get_wave_weapon_vector(weapon.length)
	wave_weapon_speed = get_wave_weapon_speed(self.strength,weapon.weight,wave_weapon_vector,weapon.length)
	wave_weapon_direction = wave_weapon_vector.normalized()
	weapon.linear_velocity += wave_weapon_direction * wave_weapon_speed * 0.8 * weapon_speed_bonus

func player_init():
	position = Vector2(70,310)
	i_am_player()
	tag = "player"
	life = max_life
	arm_length = 3

func player_weapon_init():
	weapon = weaponScene.instance()
	self.add_child(weapon)
	weapon.tag = "player_weapon"
	weapon.i_am_player_weapon()
	weapon.linear_damp = clamp(self.strength - weapon.weight + 2, 12, 18)
	weapon.angular_damp = clamp(self.strength  - weapon.weight - 1, 3, 10)
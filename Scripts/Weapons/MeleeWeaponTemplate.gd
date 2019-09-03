extends "res://Scripts/Weapons/WeaponTemplate.gd"

var pos1 = Vector2()
var pos2 = Vector2()
var linear_speed : Vector2 = pos2 - pos1

var length

var wave_weapon_vector := Vector2()
var wave_weapon_speed = 0
#var wave_weapon_direction := Vector2()

func _ready():
	pass

func _physics_process(delta):
	pos2 = self.global_position
	self.linear_speed = pos2 - pos1
	pos1 = pos2
	
	if weapon_master.tag == "player":
		if is_controlling and self.is_controllable:
			_update_wave_weapon_vector(true)
			
		else:
			_update_wave_weapon_vector(false)
		_update_wave_weapon_speed()
		if !self.is_controlling_self_with_ability and !weapon_master.is_controlling_weapon_with_ability:
			wave_weapon(wave_weapon_vector.normalized(), wave_weapon_speed)

func _update_wave_weapon_vector(is_controlling):
	var wave_length = clamp(weapon_master.vector_self_to_mouse.length(), 0, weapon_master.arm_length)
	var target_postion = weapon_master.global_position + (weapon_master.vector_self_to_mouse).normalized() * wave_length
	
	if is_controlling:
		if (target_postion - self.get_global_position()).length() <= 1.5:
			wave_weapon_vector = Vector2()
		elif (get_global_mouse_position() - self.global_position).length() < 9:
			wave_weapon_vector = Vector2()
		else:
			wave_weapon_vector = target_postion - self.get_global_position()
	else:
		if self.position.length() >= 2:
			wave_weapon_vector = - self.position * 2
		else:
			self.position = Vector2()
			wave_weapon_vector = Vector2()

func _update_wave_weapon_speed():
	#print("strength",strength)
	#print("weight",weight)
	var del = clamp(weapon_master.strength - self.weight, 3, 20)
	var speed = del * 1.2 + wave_weapon_vector.length() * 1.2
	#print("speed is",speed)
	wave_weapon_speed = speed

func wave_weapon(direction, speed):
	if !self.is_controllable:
		return
	if speed <= 3:
		return
	direction = direction.normalized()
	self.linear_velocity += direction * speed * 0.8
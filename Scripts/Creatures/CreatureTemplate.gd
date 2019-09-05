extends RigidBody2D

signal move

#一些基本属性
var max_speed = 60#最高速度
var strength = 10
var max_life = 100
var max_stamina = 100
var arm_length = 0#臂展
var alert_distance = 100
export(PackedScene) var weaponScene

var body_transform := Vector2()#用于记录子节点偏移量
var tag = "creature"
var weapon
var has_weapon
var weapon_speed
var stamina#精力
var life#生命
var total_weight = 0#总重
var attack_distance#攻击距离（武器长度加臂展）
var alive = true# 是否存活
var max_bear_damage

#用于AnimatedSprite相关
var is_ani := false
var ani#AnimatedSprite
var spr#Sprite
var towards := "none"

var velocity = Vector2()
var last_damage = 0

#挥舞武器相关变量
var weapon_speed_bonus = 1


var body_capability := {"invincible" : false, "moveable" : true, "can_use_ability" : true, "can_control_weapon" : true}
var last_time = 0
var take_damage_in_one_second = 0
var life_one_second_ago = 0 


var pos1 = Vector2()
var pos2 = Vector2()
var linear_speed := Vector2()

var DodgeCooldownTimer
var dodge_time = 0.2

onready var InvincibleTimer#无敌时间计时器
var invincible_time : float#无敌时间

onready var margin = get_node("CollisionShape2D/Margin")
onready var raycast#用来检测是否为有效攻击（有时武器会穿墙）

#位置栈#暂无内容#
var position_pool_length := 30
var position_pool_enabled := true
var position_pool

var ghost = PackedScene
var is_ghost_visible := false#残影一开始是否可见
var is_ghost_emitting := false#一开始残影不释放
var restart_ghost := true

var _update_ago_position := false
var _update_ago_position_time = dodge_time / 2
var ago_position := Vector2()

var is_controlling_self_with_ability := false
var is_controlling_weapon_with_ability := false

var timer_capability_moveable#moveable的计时器
var timer_capability_weapon#can_control_weapon的计时器
var timer_capability_ability#can_use_ability的计时器

#var _timer
var _should_update_get_hit_lose_control := true#是否更新受击硬直

var _should_update_flash = true#无敌状态时 闪烁计时器
var flash_count = 0

onready var abilities = $Abilities

func _ready():
	timer_capability_moveable = Timer.new()
	timer_capability_weapon = Timer.new()
	timer_capability_ability = Timer.new()
	timer_capability_moveable.one_shot = true
	timer_capability_moveable.wait_time = 0.01
	timer_capability_weapon.one_shot = true
	timer_capability_weapon.wait_time = 0.01
	timer_capability_ability.one_shot = true
	timer_capability_ability.wait_time = 0.01
	add_child(timer_capability_moveable)
	add_child(timer_capability_weapon)
	add_child(timer_capability_ability)
	
	
	
	_creature_init()
	_ghost_init()
	#print(invincible_time)

func _physics_process(delta):
	_update_alive_state()
	#if self.body_capability["can_use_ability"]:
		#abilities.launch_abilities()
	
	if self.linear_velocity.length() >= max_speed and body_capability["moveable"]:
		if self.is_ani:
			if !ani.visible:
				ghost.visible = false
				return
		elif !spr.visible:
			ghost.visible = false
			return
		if restart_ghost:
			restart_ghost = false
			ghost.restart()
		ghost.visible = true
	else:
		restart_ghost = true
		ghost.visible = false
	
	pos2 = self.global_position
	self.linear_speed = pos2 - pos1
	pos1 = pos2
	update_LifeBar()
	_update_max_bear_damage()
	_take_damage_inspector()
	_update_body_capability()
	_update_body_attributes()

func _flash(flash_time):
	var flash_count = 5
	var delta_time = flash_time / flash_count
	for i in flash_count * 2:
		if self.is_ani:
			ani.visible = !ani.visible
		else:
			spr.visible = !spr.visible
		yield(get_tree().create_timer(delta_time / 2), "timeout")

func rotate_weapon(speed, target_direction, delta):
	if !weapon.is_controllable:
		return
	if !has_weapon:
		return
	if !self.body_capability["can_control_weapon"]:
		return
	speed = clamp(speed, 2, 15)
	#print("rotate speed is",speed)
	var present_direction = Vector2(1, 0).rotated(weapon.global_rotation)
	weapon.global_rotation = present_direction.linear_interpolate(target_direction, speed * delta).angle()

func get_damage(damage, is_hit, attacker_position):
	#print("time is",invincible_time)
	if alive == false:	# 如果没有存活，则退出函数
		return
	if body_capability["invincible"] == true:
		print("invincible!!")
		return
	
	if is_hit:#如果是一次受击
		var judge_result = judge_whether_effective_damage(attacker_position)
		_flash(invincible_time)
		#print(judge_result)
		if judge_result:
			return
		body_capability["invincible"] = true
		InvincibleTimer.start()
	print(damage)
	#print("old life is",life)
	#print(collision_point_linear_speed)
	#print(self.linear_speed)
	life -= damage# 减少生命值
	
	pass

func _update_alive_state():#检测是否存活
	if life <= 0:
		life = 0
		_die()

func _die():
	alive = false
	queue_free()						# 自我销毁

func lose_capability_moveable(time):
	timer_capability_moveable.wait_time = timer_capability_moveable.time_left + time
	timer_capability_moveable.start()

func lose_capability_weapon(time):
	timer_capability_weapon.wait_time = timer_capability_weapon.time_left + time
	timer_capability_weapon.start()

func lose_capability_ability(time):
	timer_capability_ability.wait_time = timer_capability_ability.time_left + time
	timer_capability_ability.start()

func update_LifeBar():
	if $LifeBar.value != self.life:
		$LifeBar.value = life

func _update_max_bear_damage():
	max_bear_damage = self.max_life / 10.0 + (self.max_life / 5.0) * (stamina / max_stamina)

func _update_body_capability():
	if take_damage_in_one_second > max_bear_damage and _should_update_get_hit_lose_control:#受击硬直（一秒内所受伤害 大于 可承受伤害max_bear_damage）
		lose_capability_moveable(0.8)
		lose_capability_weapon(0.8)
		lose_capability_ability(0.8)
		_should_update_get_hit_lose_control = false
		yield(get_tree().create_timer(1), "timeout")#每一秒更新一次受击硬直的判定
		_should_update_get_hit_lose_control = true
	if timer_capability_moveable.time_left > 0:
		body_capability["moveable"] = false
	else:
		body_capability["moveable"] = true
	if timer_capability_weapon.time_left > 0:
		body_capability["can_control_weapon"] = false
	else:
		body_capability["can_control_weapon"] = true
	if timer_capability_ability.time_left > 0:
		body_capability["can_use_ability"] = false
	else:
		body_capability["can_use_ability"] = true

func _update_body_attributes():
	pass

func _take_damage_inspector():#暂时有些小问题，在生物死亡后会报一条错误，但不影响程序运行
	var old_life = life
	var _timer = Timer.new()
	add_child(_timer)
	_timer.start(1)
	yield(_timer, "timeout")
	_timer.queue_free()
	take_damage_in_one_second = old_life - self.life#过去一秒内受到的伤害
	#if self.tag == "enemy":
		#print(take_damage_in_one_second)

func judge_whether_effective_damage(target_global_position):
	raycast.enabled = true
	raycast.set_collision_mask_bit(6,true)#检测墙体
	var target_local_position = target_global_position - self.global_position
	#print("target_position",target_local_position)
	raycast.cast_to = target_local_position
	raycast.force_raycast_update()
	#print(raycast.is_colliding())
	if raycast.is_colliding():
		#raycast.enabled = false
		#raycast.set_collision_mask_bit(6, false)
		return true
	else:
		#raycast.enabled = false
		#raycast.set_collision_mask_bit(6, false)
		return false

func _on_InvincibleTimer_timeout():
	#print("invincible timer timeout")
	body_capability["invincible"] = false

func _on_DodgeCooldownTimer_timeout():
	#print("i can dodge now")
	body_capability["can_dodge"] = true

func _get_ago_position():
	if _update_ago_position:
		_update_ago_position = false
		ago_position = self.global_position
		yield(get_tree().create_timer(_update_ago_position_time), "timeout")
		_update_ago_position = true

func ai_move(direction, max_speed):
	if !body_capability["moveable"]:
		return
	var move_speed = clamp((strength - total_weight) / 1, 3, 15)
	velocity += direction * move_speed
	if velocity.length() <= max_speed:
		pass
	else:
		velocity = velocity.normalized() * max_speed
	self.linear_velocity = velocity

func ai_stop_move():
	if self.linear_velocity.length() <= 4:
		self.linear_velocity = Vector2()
		return
	var move_speed = clamp((strength - total_weight) / 1, 3, 15)
	self.linear_velocity += - self.linear_velocity.normalized() * move_speed

func judge_towards(target_global_position):#判断生物朝向
	if is_ani:
		var vec_x
		var vec_y
		vec_x = target_global_position.x - self.global_position.x
		vec_y = target_global_position.y - self.global_position.y
		if vec_x > 0:
			towards = "right"
		elif vec_x < 0:
			towards = "left"
		if self.linear_speed.length() == 0:
			towards = "none"

func update_animation():#更新动画和残影ghost
	if is_ani:
		ani.speed_scale = clamp(self.linear_velocity.length() / max_speed, 0, 2)
		if self.body_capability["moveable"] == true:
			if towards == "right":
				ani.flip_h = false
				ani.animation = "horizon"
			if towards == "left":
				ani.flip_h = true
				ani.animation = "horizon"
			if towards == "none":
				ani.animation = "idle"

func i_am_enemy():
	self.set_collision_layer_bit(1, true)
	self.set_collision_mask_bit(0, true)
	self.set_collision_mask_bit(2, true)
	self.set_collision_mask_bit(4, true)
	self.set_collision_mask_bit(6, true)

func i_am_player():
	self.set_collision_layer_bit(0, true)
	self.set_collision_mask_bit(1, true)
	self.set_collision_mask_bit(3, true)
	self.set_collision_mask_bit(5, true)
	self.set_collision_mask_bit(6, true)
	self.set_collision_mask_bit(7, true)

func _creature_init():
	self.linear_damp = 10
	self.angular_damp = 0
	self.mode = RigidBody2D.MODE_CHARACTER
	self.z_index = 1
	self.contacts_reported = 0
	self.contact_monitor = false
	#判断self是否是AnimatedSprite
	max_speed = $Attributes.max_speed
	strength = $Attributes.strength
	max_life = $Attributes.max_life
	max_stamina = $Attributes.max_stamina
	arm_length = $Attributes.arm_length
	alert_distance = $Attributes.alert_distance
	
	stamina = max_stamina
	
	life = max_life
	$LifeBar.max_value = self.max_life
	$LifeBar.value = self.life
	update_LifeBar()
	if self.has_node("AnimatedSprite"):
		$AnimatedSprite.animation = "idle"
		is_ani = true
		ani = $AnimatedSprite
		body_transform = $AnimatedSprite.position
		update_animation()
		ani.animation = "idle"
	elif self.has_node("Sprite"):
		spr = $Sprite
		body_transform = $Sprite.position
	#用来检测是否为有效攻击（因为有时武器会穿墙）#
	raycast = RayCast2D.new()
	add_child(raycast)
	raycast.set_collision_mask_bit(0,false)
	#无敌状态相关#
	invincible_time = 0.3
	InvincibleTimer = Timer.new()
	self.add_child(InvincibleTimer)
	InvincibleTimer.one_shot = true
	InvincibleTimer.wait_time = invincible_time
	InvincibleTimer.connect("timeout", self, "_on_InvincibleTimer_timeout")

func _ghost_init():
	ghost = preload("res://Assets/SpecialEffects/Ghost/Ghost.tscn").instance()
	add_child(ghost)
	ghost.visible = is_ghost_visible
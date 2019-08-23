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

#用于AnimatedSprite相关
var is_ani := false
var ani#AnimatedSprite
var spr#Sprite
var towards : String

var velocity = Vector2()

#挥舞武器相关变量
var weapon_speed_bonus = 1
var wave_weapon_vector := Vector2()
var wave_weapon_speed = 0
var wave_weapon_direction := Vector2()

var body_capability := {"invincible" : false, "controllable" : true, "can_dodge" : true}

var pos1 = self.global_position
var pos2 = self.global_position
var linear_speed : Vector2 = pos2 - pos1

var DodgeCooldownTimer
var dodge_time = 0.2

onready var InvincibleTimer#无敌时间计时器
var invincible_time : float#无敌时间

onready var margin = $Margin
onready var raycast#用来检测是否为有效攻击（有时武器会穿墙）

#位置栈#暂无内容#
var position_pool_length := 30
var position_pool_enabled := true
var position_pool

var ghost = PackedScene
var is_ghost_visible := false#残影是否可见
var is_ghost_emitting := false#一开始残影不释放

var _update_ago_position := false
var _update_ago_position_time = dodge_time / 2
var ago_position := Vector2()

func _ready():
	_creature_init()
	_ghost_init()
	#print(invincible_time)

func _physics_process(delta):
	pos2 = self.global_position
	self.linear_speed = pos2 - pos1
	pos1 = pos2
	#generate_ghost()

func rotate_weapon(speed, target_direction, delta):
	if !weapon.is_controllable:
		return
	if !has_weapon:
		return
	speed = clamp(speed, 2, 15)
	#print("rotate speed is",speed)
	var present_direction = Vector2(1, 0).rotated(weapon.global_rotation)
	weapon.global_rotation = present_direction.linear_interpolate(target_direction, speed * delta).angle()

func wave_weapon(direction, speed):
	if !weapon.is_controllable:
		return
	if !has_weapon:
		return
	#if weapon.position.length() <= 2:
		#weapon_speed_bonus = clamp((strength - weapon.weight) / 4, 1.5, 8.0)
	#print(weapon_speed_bonus)
	#weapon_speed_bonus = weapon_speed_bonus * 0.9
	#if weapon_speed_bonus <=1:
		#weapon_speed_bonus = 1
	if speed <= 3:
		return
	weapon.linear_velocity += direction * speed * 0.8

func get_damage(collision_point_linear_speed,collision_point_rotate_speed,weapon_damage,weapon_hit_tag:int,player_position):
	#print("time is",invincible_time)
	if body_capability["invincible"] == true:
		return
	var judge_result = judge_whether_effective_damage(player_position)
	#print(judge_result)
	if judge_result:
		return
	body_capability["invincible"] = true
	InvincibleTimer.start()
	#print("old life is",life)
	if alive == false:	# 如果没有存活，则退出函数
		return
	#print(collision_point_linear_speed)
	#print(self.linear_speed)
	var damage = collision_point_linear_speed.length() + abs(collision_point_rotate_speed / 2) + weapon_damage + weapon_hit_tag*2
	print("cause damage",damage)
	life -= damage# 减少生命值
	update_LifeBar()#更新生命条
	lose_control(invincible_time / 2.0)#失去控制（受击后的硬直）
	if life <= 0:
		life = 0
		$CollisionShape2D.disabled = true	# 碰撞不可用
		queue_free()						# 自我销毁
		alive = false
	pass

func update_LifeBar():
	if self.tag == "enemy":
		$LifeBar.value = life
	else:
		pass

func judge_whether_effective_damage(target_position):
	raycast.enabled = true
	raycast.set_collision_mask_bit(6,true)#检测墙体
	var target_local_position = target_position - self.global_position
	#print("target_position",target_local_position)
	raycast.cast_to = target_local_position
	raycast.force_raycast_update()
	print(raycast.is_colliding())
	if raycast.is_colliding():
		#raycast.enabled = false
		#raycast.set_collision_mask_bit(6, false)
		return true
	else:
		#raycast.enabled = false
		#raycast.set_collision_mask_bit(6, false)
		return false

func lose_control(time):
	print("lose control")
	body_capability["controllable"] = false
	yield(get_tree().create_timer(time),"timeout")
	body_capability["controllable"] = true
	print("can control")

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

func judge_towards(target_global_position):#判断人物朝向
	if is_ani:
		var vec_x
		var vec_y
		vec_x = target_global_position.x - self.global_position.x
		vec_y = target_global_position.y - self.global_position.y
		if vec_x > 0:
			towards = "right"
		elif vec_x < 0:
			towards = "left"
		elif vec_x == 0 and vec_y == 0:
			towards = "none"

func update_animation():#更新动画和残影ghost
	if is_ani:
		if self.body_capability["controllable"] == true:
			if towards == "right":
				ani.flip_h = false
				ani.animation = "horizon"
			if towards == "left":
				ani.flip_h = true
				ani.animation = "horizon"
				ghost.scale.x = -1
			if towards == "none":
				ani.animation = "idle"

func update_ghost():
	if towards == "right":
		if is_ani:
			ghost.texture = ani.frames.get_frame("horizon", ani.frame)
			ghost.scale.x = 1
			return
	if towards == "left":
		if is_ani:
			ghost.texture = ani.frames.get_frame("horizon", ani.frame)
			ghost.scale.x = -1
			return
	if !is_ani:
		ghost.texture = spr.texture
		ghost.scale.x = 1

func i_am_enemy():
	self.set_collision_layer_bit(1, true)
	self.set_collision_mask_bit(0, true)
	self.set_collision_mask_bit(2, true)
	self.set_collision_mask_bit(5, true)
	self.set_collision_mask_bit(6, true)

func i_am_player():
	self.set_collision_layer_bit(0, true)
	self.set_collision_mask_bit(1, true)
	self.set_collision_mask_bit(3, true)
	self.set_collision_mask_bit(4, true)
	self.set_collision_mask_bit(5, true)
	self.set_collision_mask_bit(6, true)

func _creature_init():
	self.linear_damp = 0
	self.angular_damp = 0
	self.mode = RigidBody2D.MODE_CHARACTER
	#判断self是否是AnimatedSprite
	if self.has_node("AnimatedSprite"):
		$AnimatedSprite.animation = "idle"
		is_ani = true
		ani = $AnimatedSprite
		body_transform = $AnimatedSprite.position
		#ani.animation = "idle"
	elif self.has_node("Sprite"):
		spr = $Sprite
		body_transform = $Sprite.position
	#用来检测是否为有效攻击（因为有时武器会穿墙）#
	raycast = RayCast2D.new()
	add_child(raycast)
	raycast.set_collision_mask_bit(0,false)
	#无敌状态相关#
	invincible_time = 15.0 / strength
	InvincibleTimer = Timer.new()
	self.add_child(InvincibleTimer)
	InvincibleTimer.one_shot = true
	InvincibleTimer.wait_time = invincible_time
	InvincibleTimer.connect("timeout", self, "_on_InvincibleTimer_timeout")

func _ghost_init():
	ghost = preload("res://Assets/SpecialEffects/Ghost/Ghost.tscn").instance()
	if is_ani:
		ghost.texture = ani.frames.get_frame("horizon", ani.frame)
	else:
		ghost.texture = spr.texture
	#ghost.emitting = is_ghost_emitting
	ghost.global_position += body_transform
	ghost.visible = is_ghost_visible
	#print(body_transform)
	add_child(ghost)
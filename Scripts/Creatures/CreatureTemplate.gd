extends RigidBody2D

#一些属性
export(int) var max_speed = 100#最高速度
export(int) var strength = 20
export(int) var max_life = 100
export(int) var max_stamina = 100
export(PackedScene) var weaponScene

var tag = "creature"
var weapon
var weapon_speed
var stamina
var life
var alive = true		# 是否存活

var velocity = Vector2()

onready var weapon_vector:Vector2

var weapon_speed_bonus
var is_invincible := false
var can_control_self := true

var pos1 = self.global_position
var pos2 = self.global_position
var linear_speed : Vector2 = pos2 - pos1

var DodgeCooldownTimer
var can_dodge = true

onready var InvincibleTimer#无敌时间计时器
var invincible_time : float#无敌时间


onready var margin = $Margin
onready var raycast#用来检测是否为有效攻击（有时武器会穿墙）

func _ready():
	raycast = RayCast2D.new()
	add_child(raycast)
	
	DodgeCooldownTimer = Timer.new()
	add_child(DodgeCooldownTimer)
	DodgeCooldownTimer.one_shot = true
	DodgeCooldownTimer.wait_time = 1.5
	#print(DodgeCooldownTimer.wait_time)
	DodgeCooldownTimer.connect("timeout", self, "_on_DodgeCooldownTimer_timeout")
	
	invincible_time = 15.0 / strength
	#print("hhh",invincible_time)
	InvincibleTimer = Timer.new()
	self.add_child(InvincibleTimer)
	InvincibleTimer.one_shot = true
	InvincibleTimer.wait_time = invincible_time
	InvincibleTimer.connect("timeout", self, "_on_InvincibleTimer_timeout")
	
	#print("my strength is",strength)
	#print("time is",invincible_time)
	
func _physics_process(delta):
	#print("time is",invincible_time)
	pos2 = self.global_position
	self.linear_speed = pos2 - pos1
	pos1 = pos2

func get_damage(collision_point_linear_speed,collision_point_rotate_speed,weapon_damage,weapon_hit_tag:int,player_position):
	#print("time is",invincible_time)
	if is_invincible:
		return
	var judge_result = judge_whether_effective_damage(player_position)
	#print(judge_result)
	if judge_result:
		return
	is_invincible = true
	InvincibleTimer.start()
	#print("old life is",life)
	if alive == false:	# 如果没有存活，则退出函数
		return
	#print(collision_point_linear_speed)
	#print(self.linear_speed)
	var damage = (collision_point_linear_speed - self.linear_speed).length() + abs(collision_point_rotate_speed / 2) + weapon_damage + weapon_hit_tag*2
	print("cause damage",damage)
	life -= damage# 减少生命值
	update_LifeBar()#更新生命条
	lose_control(InvincibleTimer.wait_time / 2.0)#失去控制（受击后的硬直）
	if life <= 0:
		life = 0
		$CollisionShape2D.disabled = true	# 碰撞不可用
		queue_free()						# 自我销毁
		alive = false
	pass

func update_LifeBar():
	if self.tag == "enemy":
		$LifeBar.value = (float(life) / max_life) * 100
	else:
		return

func judge_whether_effective_damage(target_position):
	raycast.enabled = true
	raycast.set_collision_mask_bit(0,false)
	raycast.set_collision_mask_bit(6,true)#检测墙体
	var target_local_position = target_position - self.global_position
	#print("target_position",target_local_position)
	raycast.cast_to = target_local_position
	raycast.force_raycast_update()
	print(raycast.is_colliding())
	if raycast.is_colliding():
		raycast.enabled = false
		raycast.set_collision_mask_bit(6, false)
		return true
	else:
		raycast.enabled = false
		raycast.set_collision_mask_bit(6, false)
		return false

func lose_control(time):
	print("lose control",invincible_time)
	self.can_control_self = false
	yield(get_tree().create_timer(time),"timeout")
	self.can_control_self = true
	print("can control")

func _on_InvincibleTimer_timeout():
	#print("invincible timer timeout")
	is_invincible = false

func _on_DodgeCooldownTimer_timeout():
	print("i can dodge now")
	can_dodge = true

func dodge():#冲刺
	if can_dodge:
		var dodge_time = 0.25
		#print("dodging")
		self.linear_velocity = velocity * clamp(self.strength / 3.0, 1, 20)
		weapon.linear_velocity = velocity * clamp(self.strength / 3.0, 1, 20)
		yield(get_tree().create_timer(dodge_time), "timeout")
		#print("finish dodge")
		can_dodge = false
		DodgeCooldownTimer.start()



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
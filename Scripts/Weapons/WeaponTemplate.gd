extends RigidBody2D

signal hit_sth

#一些武器基本属性
var level = 0
var value = 0


var tag : String = "weapon"#player_weapon or enemy_weapon or weapon
var type : String#melee or ranged or magic
var ranged_weapon_type : String#bow, crossbow, gun

var basic_damage
var collision_tag = {"obtuse":0.5, "sharp":2}


var rot1 = 0
var rot2 = 0
var rotate_speed : float = rot2 - rot1

var weapon_master

var is_stuck:= false
var is_controllable = true
var is_controlling_self_with_ability := false
var is_controlling_master_with_ability := false
var is_controlling = false
onready var margin = $Margin

func _ready():
	weapon_init()

func _process(delta):
	#print(self.angular_velocity)
	#print(self.linear_speed)
	rot2 = self.global_rotation
	#print(self.global_rotation)
	if rot1 * rot2 >= 0 or (abs(rot1) < (PI / 2) and abs(rot2) < (PI / 2)):
		self.rotate_speed = rot2 - rot1
	elif rot1 > 0 and rot2 < 0:
		self.rotate_speed = (PI - rot1) + (PI + rot2)
	else:#rot 1 < 0 and rot2 > 0
		self.rotate_speed =  (PI - rot2) + (PI + rot1)
	rot1 = rot2
	
	if self.weapon_master.has_method("_creature_init"):
		if self.global_rotation < 0:
			self.z_index = -1
		else:
			self.z_index = 1

func _on_Weapon_body_entered(body,weapon_linear_speed:Vector2,weapon_damage:float,weapon_hit_tag:String):
	#print("weapon_hit_tag_is",weapon_hit_tag)
	#print("enter!")
	#print("it`s tag is", body.tag)
	#以下if是判断并避免自己误伤自己人
	if (self.tag == "player_weapon" and body.tag == "enemy") or (self.tag == "enemy_weapon" and body.tag == "player") or self.tag == "weapon":
		pass
		#print("!!!!!!!!!!!")
	else:
		return
	#emit_signal("hit_body",body.global_position)
	var body_margin_position_array = body.margin.curve.get_baked_points()
	var arr_e = body_margin_position_array#敌人身形的local position
	var arr_local = []#body身形在 武器坐标系中的 local position
	var arr_length = []
	var arr_closest = []
	var length_1 = 10000
	var length_2 = 0
	#print(margin.curve.get_baked_points())
	for i in arr_e.size():
		arr_e[i] += body.global_position#将body的轮廓local position转换为global position
		arr_local.append(arr_e[i] - self.global_position)#body轮廓在 武器坐标系中的 local position
		var w_closest_pos = self.margin.curve.get_closest_point(arr_local[i])#武器轮廓曲线上 到 敌人轮廓的local position 最近的点
		var w_global_pos = w_closest_pos + self.global_position
		length_2 = (w_global_pos - arr_e[i]).length()
		if length_2 < length_1:
			arr_closest.append(w_closest_pos)
			arr_length.append(length_2)
			length_1 = length_2
	#print(arr_closest[arr_closest.size()-1])
	#print(arr_length[arr_length.size()-1])
	var collision_point_local = arr_closest[arr_closest.size()-1]#碰撞点在武器轮廓上的local position
	#print(collision_point_local)
	var collision_point_radius = collision_point_local.length()
	var collision_point_linear_speed = self.linear_speed
	var collision_point_rotate_speed = self.rotate_speed * collision_point_radius
	#print("collision_point_linear_speed",collision_point_linear_speed)
	#print("collision_point_angular_speed",collision_point_rotate_speed)
	#print("body!")
	var player_position = self.global_position - self.position
	var damage = ((collision_point_linear_speed - body.linear_speed).length() / 2 + abs(collision_point_rotate_speed / 3)) * weapon_damage * collision_tag[weapon_hit_tag]
	if damage > 50:
		print("匪夷所思的高额伤害！伤害值为：", damage)
		print("武器上的碰撞点线速度为：", collision_point_linear_speed)
		print("武器上的碰撞点半径为：", collision_point_radius)
		print("武器上的碰撞点角速度为：", rotate_speed)
		print("武器上的碰撞点旋转速度为", collision_point_rotate_speed)
		print("受击者的线速度为：", body.linear_speed)
	
	body.get_damage(damage, true, get_parent().global_position)

func update_basic_damage():
	basic_damage = weight * 0.15 + level * 0.15 + value * 0.1

func i_am_player_weapon():
	clear_collision_bit(self)
	self.angular_damp = 8
	self.tag = "player_weapon"
	self.set_collision_mask_bit(1,true)
	self.set_collision_mask_bit(3,true)
	self.set_collision_mask_bit(5,true)
	self.set_collision_mask_bit(6,true)
	self.set_collision_layer_bit(2,true)
	if self.has_node("ObtuseArea"):
		var obtuse_area = $ObtuseArea
		clear_collision_bit(obtuse_area)
		obtuse_area.set_collision_mask_bit(1,true)
		obtuse_area.set_collision_mask_bit(3,true)
		obtuse_area.set_collision_mask_bit(5,true)
		obtuse_area.set_collision_mask_bit(6,true)
		obtuse_area.set_collision_layer_bit(2,true)
	if self.has_node("SharpArea"):
		var sharp_area = $SharpArea
		clear_collision_bit(sharp_area)
		sharp_area.set_collision_mask_bit(1,true)
		sharp_area.set_collision_mask_bit(3,true)
		sharp_area.set_collision_mask_bit(5,true)
		sharp_area.set_collision_mask_bit(6,true)
		sharp_area.set_collision_layer_bit(2,true)

func i_am_enemy_weapon():
	clear_collision_bit(self)
	self.angular_damp = 8
	self.tag = "enemy_weapon"
	self.set_collision_mask_bit(0,true)
	self.set_collision_mask_bit(2,true)
	self.set_collision_mask_bit(4,true)
	self.set_collision_mask_bit(6,true)
	self.set_collision_layer_bit(3,true)
	if self.has_node("ObtuseArea"):
		var obtuse_area = $ObtuseArea
		clear_collision_bit(obtuse_area)
		obtuse_area.set_collision_mask_bit(0,true)
		obtuse_area.set_collision_mask_bit(2,true)
		obtuse_area.set_collision_mask_bit(4,true)
		obtuse_area.set_collision_mask_bit(6,true)
		obtuse_area.set_collision_layer_bit(3,true)
	if self.has_node("SharpArea"):
		var sharp_area = $SharpArea
		clear_collision_bit(sharp_area)
		sharp_area.set_collision_mask_bit(0,true)
		sharp_area.set_collision_mask_bit(2,true)
		sharp_area.set_collision_mask_bit(4,true)
		sharp_area.set_collision_mask_bit(6,true)
		sharp_area.set_collision_layer_bit(3,true)

func clear_collision_bit(target):
	for i in 9:
		target.set_collision_mask_bit(i, false)
		target.set_collision_layer_bit(i, false)

func set_tag_and_type(tag:String,type:String):
	self.tag = tag
	self.type = type

func weapon_init():
	if self.get_parent().has_method("ai_move"):
		weapon_master = get_parent()
	
	self.linear_damp = 0.3 if weapon_master == null else weapon_master.linear_damp
	self.angular_damp = 0.3
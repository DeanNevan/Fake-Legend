extends "res://Scripts/Creatures/CreatureTemplate.gd"

signal notice_player

var has_noticed_player := false#是否注意到了player
var is_catching_player := false#是否在追逐player
var is_searching_player := false#是否在搜寻player
var is_in_combat := false#是否处于战斗中

var ai_state := "unaware"#unaware,noticed,catching,combating,searching
var combat_mode : String#far（远距离攻击）, front（正面攻击）, back（周旋&绕后攻击）

var vector_self_to_player := Vector2()
var distance_self_to_player := 1000.0
var is_player_in_alert_range := false

var path = []
var goal = Vector2()

var move_vector := Vector2()
var move_speed = 0

var player_disapear_global_position := Vector2()
var player_in_room_position := Vector2()
var self_in_room_position := Vector2()

onready var sight_line = RayCast2D.new()#敌人视线（由自己指向player）（不是视野）
onready var main = self.get_parent().get_parent().get_parent().get_parent()
onready var player = main.get_node("Player")
onready var my_room = self.get_parent().get_parent()
onready var nav = my_room.get_node_or_null("Navigation2D")

func _ready():
	preload("res://Scripts/Creatures/CreatureTemplate.gd")
	#player.connect("move", self, "update_path")
	_enemy_init()
	_enemy_weapon_init()
	_judge_combat_mode()
	print(combat_mode)

func _physics_process(delta):
	#var arr = get_tree().get_nodes_in_group("enemies")
	#player_position = arr[0].player_position
	#print(player.global_position)
	#print(sight_line.is_colliding())
	player_in_room_position = player.global_position - my_room.global_position
	self_in_room_position = self.global_position - my_room.global_position
	vector_self_to_player = player_in_room_position - self_in_room_position
	distance_self_to_player = vector_self_to_player.length()
	if distance_self_to_player <= alert_distance:
		sight_line.cast_to = player.global_position - self.global_position
		sight_line.force_raycast_update()
		is_player_in_alert_range = true
	else:
		sight_line.enabled = false
		is_player_in_alert_range = false
	
	vector_self_to_player = player.global_position - self.global_position
	distance_self_to_player = vector_self_to_player.length()
	
	match ai_state:
		"unaware":
			ai_state_alert()
		"noticing":
			ai_state_notice()
			emit_signal("notice_player")
		"catching":
			ai_state_catch()
			emit_signal("notice_player")
		"combating":
			ai_state_combat()
			emit_signal("notice_player")
		"searching":
			ai_state_search()
	#print(ai_state)
#func set_nav(new_nav):
	#nav = new_nav
	#update_path()

func _draw():
	#yield(get_tree().create_timer(2), "timeout")
	#print("!!!!!")
	for i in range(1,path.size()):
		#print(path[i-1])
		#print(path[i])
		#print(self.position)
		draw_line(path[i-1] - self_in_room_position, path[i] - self_in_room_position, Color.darkred, 4)

func ai_state_alert():
	sight_line.force_raycast_update()
	#print(sight_line.is_colliding())
	if !sight_line.is_colliding() and is_player_in_alert_range == true:
		ai_state = "noticing"

func ai_state_notice():
	ai_state = "catching"

func ai_state_catch():
	if sight_line.is_colliding() or !is_player_in_alert_range:
		player_disapear_global_position = player.global_position
		ai_state = "searching"#
		return
	if !sight_line.is_colliding() and (distance_self_to_player <= self.attack_distance):#当与玩家间无墙体阻碍以及距离小于自己攻击距离时 进入作战ai
		ai_state = "combating"
		return
	_update_path()
	_get_move_vector()
	ai_move(move_vector.normalized(), max_speed)
	pass

func ai_state_combat():
	if distance_self_to_player > (attack_distance + alert_distance / 2):
		ai_state = "catching"
	

func ai_state_search():
	if !sight_line.is_colliding() and is_player_in_alert_range == true:
		ai_state = "noticing"
		return
	if ((player_disapear_global_position - my_room.global_position) - self_in_room_position).length() > 5:#如果玩家消失位置离自己大于1像素，则朝玩家消失为止搜索
		ai_search(player_disapear_global_position - my_room.global_position)
	else:
		ai_stop_move()
		#做一些其他的search行为
		pass
	pass

func ai_move(direction, max_speed):
	move_speed += clamp((strength - total_weight) / 1.5, 2.5, 15)
	move_speed = clamp(move_speed, 0, max_speed)
	self.linear_velocity = direction.normalized() * move_speed

func ai_stop_move():
	move_speed -= clamp((strength - total_weight) / 1.5, 2.5, 15)
	move_speed = clamp(move_speed, 0, max_speed)
	self.linear_velocity = self.linear_velocity.normalized() * move_speed

func ai_search(target_position):
	path = nav.get_simple_path(self_in_room_position, target_position, true)
	_get_move_vector()
	update()
	ai_move(move_vector.normalized(), max_speed)

func ai_dodge(direction):
	pass

func _update_path():
	sight_line.force_raycast_update()
	path = nav.get_simple_path(self_in_room_position, player_in_room_position, true)
	update()
	#print(path)

func _get_move_vector():
	if path.size() > 1:
		move_vector = path[1] - self_in_room_position
	else:
		move_vector = Vector2()
	#print(move_vector)

func _judge_combat_mode():
	if weaponScene != null:
		if weapon.type == "ranged" or weapon.type == "magic":
			self.combat_mode = "far"
		elif attack_distance < 25:
			self.combat_mode = "back"
		else:
			self.combat_mode = "front"
	else:
		if self.attack_distance < 12:
			self.combat_mode = "back"
		else:
			self.combat_mode = "front"

func _enemy_init():
	self.tag = "enemy"
	self.add_to_group("enemies")#添加到组enemies中
	i_am_enemy()
	life = max_life
	$LifeBar.max_value = self.max_life
	$LifeBar.value = self.life
	self.add_child(sight_line)
	sight_line.set_collision_mask_bit(0,false)
	sight_line.set_collision_mask_bit(6,true)#检测墙体
	sight_line.enabled = false
	sight_line.force_raycast_update()

func _enemy_weapon_init():
	if weaponScene != null:
		has_weapon = true
		weapon = weaponScene.instance()
		self.add_child(weapon)
		weapon.add_to_group("enemy_weapon")
		weapon.tag = "enemy_weapon"
		weapon.i_am_enemy_weapon()
		#print(total_weight)
		total_weight = self.weight + weapon.weight#人物与武器总重
		self.attack_distance = self.arm_length + weapon.length
			
	else:
		has_weapon = false
		total_weight = self.weight
		self.attack_distance = self.arm_length
		#print(attack_distance)
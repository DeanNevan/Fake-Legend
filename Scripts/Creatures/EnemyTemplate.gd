extends "res://Scripts/Creatures/CreatureTemplate.gd"

signal notice_player

export(int) var alert_scope = 150
var attack_distance#攻击距离（武器长度加臂展）

var has_noticed_player := false#是否注意到了player
var is_catching_player := false#是否在追逐player
var is_searching_player := false#是否在搜寻player
var is_in_combat := false#是否处于战斗中

var ai_state := "unaware"#unaware,noticed,catching,combating,searching

var vector_self_to_player := Vector2()
var distance_self_to_player := 1000.0

#var nav = null setget set_nav
var path = []
var goal = Vector2()

onready var sight_line = RayCast2D.new()#敌人视线（由自己指向player）（不是视野）
onready var main = self.get_parent().get_parent().get_parent().get_parent().get_parent()
onready var player = main.get_node("Player")
onready var nav = main.get_node("Navigation2D")

func _ready():
	#player.connect("move", self, "update_path")
	self.add_to_group("enemies")#添加到组enemies中
	_enemy_init()
	_enemy_weapon_init()

func _physics_process(delta):
	#var arr = get_tree().get_nodes_in_group("enemies")
	#player_position = arr[0].player_position
	#print(player.global_position)
	
	if distance_self_to_player <= alert_scope:
		sight_line.cast_to = player.global_position - self.global_position
		sight_line.enabled = true
	else:
		sight_line.enabled = false
	
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

#func set_nav(new_nav):
	#nav = new_nav
	#update_path()

func _update_path():
	path = nav.get_simple_path(self.global_position, player.global_position, false)

func ai_state_alert():
	#sight_line.force_raycast_update()
	if !sight_line.is_colliding():
		ai_state = "noticing"

func ai_state_notice():
	ai_state = "catching"

func ai_state_catch():
	if player.linear_speed != Vector2():
		_update_path()
		print(path)
	pass

func ai_state_combat():
	pass

func ai_state_search():
	pass

func ai_run(direction,speed):
	pass

func ai_dodge(direction):
	pass

func _enemy_init():
	self.tag = "enemy"
	i_am_enemy()
	life = max_life
	$LifeBar.max_value = self.max_life
	$LifeBar.value = self.life
	self.add_child(sight_line)
	sight_line.set_collision_mask_bit(0,false)
	sight_line.set_collision_mask_bit(6,true)#检测墙体

func _enemy_weapon_init():
	weapon = weaponScene.instance()
	self.add_child(weapon)
	weapon.tag = "enemy_weapon"
	weapon.i_am_enemy_weapon()
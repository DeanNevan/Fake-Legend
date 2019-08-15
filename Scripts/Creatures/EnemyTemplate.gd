extends "res://Scripts/Creatures/CreatureTemplate.gd"

export(int) var alert_scope = 100
var attack_distance#攻击距离（武器长度加臂展）

var is_noticed_player := false#是否注意到了player
var is_catching_player := false#是否在追逐player
var is_searching_player := false#是否在搜寻player
var is_in_combat := false#是否处于战斗中

var player_position#声明player_position 其值已被main节点中的set_group()设置

onready var sight_line = RayCast2D.new()#敌人视线（由自己指向player）（不是视野）

func _ready():
	self.add_to_group("enemies")#添加到组enemies中
	enemy_init()
	enemy_weapon_init()
	self.add_child(sight_line)
	
	

func _physics_process(delta):
	#var arr = get_tree().get_nodes_in_group("enemies")
	#player_position = arr[0].player_position
	#print(player_position)
	pass

func enemy_init():
	self.tag = "enemy"
	i_am_enemy()
	life = max_life
	$LifeBar.max_value = self.max_life
	$LifeBar.value = self.life

func enemy_weapon_init():
	weapon = weaponScene.instance()
	self.add_child(weapon)
	weapon.tag = "enemy_weapon"
	weapon.i_am_enemy_weapon()

func ai_look():
	pass
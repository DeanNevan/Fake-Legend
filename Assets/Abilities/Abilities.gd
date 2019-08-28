extends Node

# 每一个生物（玩家，敌人）场景都应当有这个Abilities节点作为第一级子节点
#在本节点下增加各种 能力/技能
#各种 能力/技能 都有自己的launch（）方法，判断是否发动技能的代码就在launch（）内，这个脚本中不做判断，仅仅起到获取所有能力以及调用的功能

var abilities_count

# Called when the node enters the scene tree for the first time.
func _ready():
	update_abilities_arr()

func update_abilities_arr():
	abilities_count = get_child_count()

func launch_abilities():
	if abilities_count != 0:
		for i in abilities_count:
			get_child(i).launch()
			#print(get_child(i))

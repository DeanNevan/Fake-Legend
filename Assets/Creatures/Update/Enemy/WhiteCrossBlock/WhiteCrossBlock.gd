extends "res://Scripts/Creatures/EnemyTemplate.gd"

func _ready():
	preload("res://Scripts/Creatures/EnemyTemplate.gd")
	max_speed = 60
	strength = 16
	max_life = 120
	max_stamina = 80
	arm_length = 20
	alert_distance = 120

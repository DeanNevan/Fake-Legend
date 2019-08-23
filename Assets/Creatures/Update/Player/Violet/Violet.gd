extends "res://Scripts/Creatures/PlayerTemplate.gd"


func _ready():
	preload("res://Scripts/Creatures/PlayerTemplate.gd")
	max_speed = 60
	strength = 16
	max_life = 120
	max_stamina = 80
	arm_length = 20
	alert_distance = 120

func _process(delta):
	pass
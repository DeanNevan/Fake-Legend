extends "res://Scripts/Weapons/BowTemplate.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	preload("res://Scripts/Weapons/BowTemplate.gd")
	weight = 11
	level = 4
	value = 100
	strength = 400
	update_basic_damage()
	pull_string_array = [3, 5, 7, 9, 11]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

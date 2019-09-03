extends "res://Scripts/Projectiles/ProjectileTemplate.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	preload("res://Scripts/Projectiles/ProjectileTemplate.gd")
	type = "arrow"
	level = 1
	value = 10
	update_basic_damage()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

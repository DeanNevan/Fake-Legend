extends "res://Scripts/Weapons/WeaponTemplate.gd"

var pos1 = Vector2()
var pos2 = Vector2()
var linear_speed : Vector2 = pos2 - pos1

func _ready():
	damage = weight * 0.15 + level * 0.15 + value * 0.1

func _physics_process(delta):
	pos2 = self.global_position
	self.linear_speed = pos2 - pos1
	pos1 = pos2
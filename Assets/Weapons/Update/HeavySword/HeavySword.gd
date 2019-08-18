extends "res://Scripts/Weapons/WeaponTemplate.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	level = 3
	value = 25
	length = 74
	set_tag_and_type("weapon","melee")

func _on_SharpArea_body_entered(body, weapon_hit_type):
	_on_Weapon_body_entered(body,self.linear_speed,self.damage,weapon_hit_type)


func _on_ObtuseArea_body_entered(body, weapon_hit_type):
	_on_Weapon_body_entered(body,self.linear_speed,self.damage,weapon_hit_type)
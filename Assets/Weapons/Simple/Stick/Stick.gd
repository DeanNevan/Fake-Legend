extends "res://Scripts/Weapons/WeaponTemplate.gd"

func _ready():
	set_tag_and_type("weapon","melee")

func _on_ObtuseArea_body_entered(body,weapon_hit_type):
	_on_Weapon_body_entered(body,self.linear_speed,self.damage,weapon_hit_type)

func _on_Stick_body_entered(body):
	emit_signal("hit_sth",body)

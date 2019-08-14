extends "res://Scripts/Creatures/CreatureTemplate.gd"

func _ready():
	weapon = weaponScene.instance()
	self.add_child(weapon)
	life = max_life
	weapon.tag = "enemy_weapon"
	self.tag = "enemy"
	weapon.i_am_enemy_weapon()
	i_am_enemy()
	$LifeBar.max_value = self.max_life
	$LifeBar.value = self.life
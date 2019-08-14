extends TileMap

var tag = "TileMap"


func _ready():
	self.set_collision_layer_bit(6, true)
	self.set_collision_mask_bit(0, true)
	self.set_collision_mask_bit(1, true)
	self.set_collision_mask_bit(2, true)
	self.set_collision_mask_bit(3, true)
	self.set_collision_mask_bit(7, true)
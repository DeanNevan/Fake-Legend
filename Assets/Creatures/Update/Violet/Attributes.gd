extends "res://Scripts/Creatures/AttributesTemplate.gd"
# Called when the node enters the scene tree for the first time.
func _ready():
	max_speed = 60
	strength = 36
	max_life = 250
	max_stamina = 80
	arm_length = 20
	alert_distance = 150

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(get_parent().life)
	pass

extends Node

var max_speed
var strength
var max_life
var max_stamina
var arm_length
var alert_distance

# Called when the node enters the scene tree for the first time.
func _ready():
	max_speed = 60
	strength = 16
	max_life = 120
	max_stamina = 80
	arm_length = 20
	alert_distance = 150

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

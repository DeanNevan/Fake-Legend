extends Node2D

onready var camera = $Camera2D
onready var player = $Player

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateCameraPosition()

func updateCameraPosition():
	camera.position = player.position
extends Node2D

onready var camera = $Camera2D
onready var player = $Player
#var player_position := Vector2()
#var player = preload("res://Assets/Creatures/Update/Violet/Violet.tscn")

func _ready():
	#player.instance()
	#self.add_child(player)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateCameraPosition()
	#get_tree().set_group("enemies", "player_position", player.global_position)

func updateCameraPosition():
	camera.global_position = player.global_position
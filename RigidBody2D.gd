extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var start_timer := true
var timer
# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.start(3)

func _process(delta):
	pass

func _on_RigidBody2D_body_entered(body):
	print(body.name)

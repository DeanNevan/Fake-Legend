extends Node2D

var timer

func _ready():
	timer = Timer.new()
	self.add_child(timer)
	timer.wait_time = 2*0.33
	print("time is",timer.wait_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

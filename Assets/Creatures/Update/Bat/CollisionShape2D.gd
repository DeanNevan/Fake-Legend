extends CollisionShape2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var ani = get_parent().get_node("AnimatedSprite")
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if ani.animation == "horizon":
		if ani.frame == 0:
			self.position = Vector2(0, 2)
			self.shape.radius = 4.25
			self.shape.height = 1.35
		if ani.frame == 1:
			self.position = Vector2(0, 0)
			self.shape.radius = 4.25
			self.shape.height = 1.35
		if ani.frame == 2:
			self.position = Vector2(1, 0)
			self.shape.radius = 4.25
			self.shape.height = 1.35

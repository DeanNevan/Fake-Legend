extends RigidBody2D
##
var tag = "projectile"
var type = "projectile"

var generate_frame = 0

var level = 1
var value = 10
var basic_damage

var pos1 = Vector2()
var pos2 = Vector2()
var linear_speed : Vector2 = pos2 - pos1

var life_time = 2#可以飞行的时间

var is_flying = false
var is_being_pulled = true#弓箭专用
var should_update_pull_string = true

var weapon
var timer_flying#飞行时间计时器

func _ready():
	_projectile_init()

func _process(delta):
	pos2 = self.global_position
	self.linear_speed = pos2 - pos1
	pos1 = pos2
	
	if generate_frame == get_tree().get_frame():
		self.visible = false
	else:
		self.visible = true
	
	if is_being_pulled and self.type == "arrow":
		self.z_index = weapon.z_index + 1
		self.global_position = weapon.global_position + weapon.string_offset
		self.global_rotation = weapon.global_rotation
	
	if timer_flying.time_left == 0:
		_free()

func _on_body_entered(body):
	if body.tag == "TileMap":
		_free()
	if body.tag != weapon.weapon_master.tag and body.has_method("get_damage"):
		var damage = ((self.linear_speed - body.linear_speed).length() / 2.5) * (basic_damage + weapon.basic_damage)
		body.get_damage(((self.linear_speed - body.linear_speed).length() / 2.5) * (basic_damage + weapon.basic_damage), true, self.global_position - body.global_position)
		print("shoot target!!!", damage)
		_free()

func _free():
	self.queue_free()

func update_basic_damage():
	basic_damage = weight * 0.15 + level * 0.15 + value * 0.1

func start_fly():
	timer_flying.start(life_time)
	is_being_pulled = false
	should_update_pull_string = true
	is_flying = true
	if weapon.tag == "player_weapon":
		tag = "player_projectile"
		self.set_collision_layer_bit(4, true)
		self.set_collision_mask_bit(1,true)
		self.set_collision_mask_bit(3,true)
		self.set_collision_mask_bit(5,true)
		self.set_collision_mask_bit(6,true)
	if weapon.tag == "enemy_weapon":
		tag = "enemy_projectile"
		self.set_collision_layer_bit(5, true)
		self.set_collision_mask_bit(0,true)
		self.set_collision_mask_bit(2,true)
		self.set_collision_mask_bit(4,true)
		self.set_collision_mask_bit(6,true)
	

func clear_collision_bit(target):
	for i in 9:
		target.set_collision_mask_bit(i, false)
		target.set_collision_layer_bit(i, false)

func _projectile_init():
	clear_collision_bit(self)
	
	self.linear_damp = 0.5
	self.angular_damp = 0.5
	self.connect("body_entered", self, "_on_body_entered")
	self.contact_monitor = true
	self.contacts_reported = 3
	
	timer_flying = Timer.new()
	timer_flying.one_shot = true
	add_child(timer_flying)
	timer_flying.start(life_time)
	
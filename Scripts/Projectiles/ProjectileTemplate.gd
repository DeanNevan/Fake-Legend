extends RigidBody2D
##
signal free

var tag = "projectile"
var type = "projectile"

var generate_frame = 0

var level = 1
var value = 10
var basic_damage

var pos1 = Vector2()
var pos2 = Vector2()
var linear_speed : Vector2 = pos2 - pos1

var initial_velocity = Vector2(1, 1)

var life_time = 2#可以飞行的时间

var is_entered = false
var is_freeing = false
var is_flying = false
var is_being_pulled = true#弓箭专用
var should_update_pull_string = true

var ani
var weapon
var timer_flying#飞行时间计时器

func _ready():
	_projectile_init()
	ani = $AnimatedSprite

func _process(delta):
	
	if is_freeing:
		return
	
	if is_flying:
		#print(linear_velocity)
		ani.speed_scale = self.linear_velocity.length() / initial_velocity.length()
	
	pos2 = self.global_position
	self.linear_speed = pos2 - pos1
	pos1 = pos2
	
	if generate_frame == get_tree().get_frame():
		self.visible = false
	else:
		self.visible = true
	
	if is_being_pulled and self.type == "arrow" and weapon != null:
		self.z_index = weapon.z_index + 1
		self.global_position = weapon.global_position + weapon.string_offset
		self.global_rotation = weapon.global_rotation
	
	if timer_flying.time_left == 0:
		is_flying = false
		_free()

func _on_body_entered(body):
	if !is_entered:
		is_entered = true
		if body.tag == "TileMap":
			self.linear_velocity *= 0.5
		if body.tag != weapon.weapon_master.tag and body.has_method("get_damage"):
			var damage = ((self.linear_speed - body.linear_speed).length() / 2.5) * (basic_damage + weapon.basic_damage)
			body.get_damage(((self.linear_speed - body.linear_speed).length() / 2.5) * (basic_damage + weapon.basic_damage), true, body.global_position)
			print("shoot target!!!", damage)
			_free()

func _free():
	emit_signal("tree_exiting")
	is_freeing = true
	self.queue_free()

func update_basic_damage():
	basic_damage = weight * 0.15 + level * 0.15 + value * 0.1

func start_fly(velocity):
	initial_velocity = velocity
	ani.play("flying")
	self.linear_velocity = velocity
	timer_flying.paused = false
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
	self.can_sleep = false
	
	clear_collision_bit(self)
	
	self.linear_damp = 1
	self.angular_damp = 3
	self.connect("body_entered", self, "_on_body_entered")
	self.contact_monitor = true
	self.contacts_reported = 5
	
	timer_flying = Timer.new()
	timer_flying.one_shot = true
	add_child(timer_flying)
	timer_flying.wait_time = life_time
	timer_flying.start()
	timer_flying.paused = true
	
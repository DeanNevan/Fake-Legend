extends "res://Scripts/Weapons/WeaponTemplate.gd"

var max_range_distance#最大射程
var strength
#var tightness_degree#弦的松紧度
#var is_automatic#是否自动连发
var time_ready_to_max_shoot#从开始攻击到达到最大伤害的时间（弓类武器就是拉弦时间，枪支类就是0）
var time_of_every_shoot_frame

var time_to_fully_release
var time_of_every_release_frame

var idle_frames_count#空闲动画帧数量
var shoot_frames_count#射击动画帧数量
var release_frames_count#射击后动画帧数量

var pull_string_array := []#用于记录拉弦时弦后退的像素格数
var timer_pull_string
var string_offset := Vector2()

var ani

var can_shoot = true
var is_updating_animation = false
var is_pulling = false
var is_releasing = false
 
export (PackedScene) var arrow
# Called when the node enters the scene tree for the first time.
func _ready():
	bow_init()
	update_basic_damage()

func _process(delta):
	self.global_position = weapon_master.global_position
	
	if is_pulling:
		if timer_pull_string.time_left == 0:
			string_offset = pull_string_array[pull_string_array.size()]
		string_offset = - Vector2(cos(self.global_rotation), sin(self.global_rotation)) * pull_string_array[floor((time_ready_to_max_shoot - timer_pull_string.time_left) / time_of_every_shoot_frame)]
	else:
		string_offset = Vector2()
	
	if weapon_master.tag == "player":
		if is_controlling and !is_controlling_self_with_ability and !weapon_master.is_controlling_weapon_with_ability:
			ai_shoot(weapon_master.vector_self_to_mouse.normalized())

func _start(pull_time):
	timer_pull_string.start(time_ready_to_max_shoot)
	ani.speed_scale = 1 / time_ready_to_max_shoot
	ani.animation = "shoot"

func _release():
	is_pulling = false
	ani.speed_scale = 1 / time_to_fully_release
	ani.animation = "release"

func ai_shoot(direction, pull_time = time_ready_to_max_shoot):
	if !is_pulling and can_shoot:
		is_pulling = true
		can_shoot = false
		_start(pull_time)
		arrow_init()
		arrow.visible = false
		get_node("/root/Main").add_child(arrow)
		arrow.generate_frame = get_tree().get_frame()
		arrow.is_being_pulled = true
		arrow.weapon = self
		yield(timer_pull_string, "timeout")
		is_pulling = false
		_release()
		arrow.linear_velocity =  Vector2(cos(self.global_rotation), sin(self.global_rotation)) * (pull_time / time_ready_to_max_shoot) * strength
		arrow.start_fly()
		yield(get_tree().create_timer(time_to_fully_release), "timeout")
		can_shoot = true
		ani.speed_scale = 1 
		ani.animation = "idle"
		

func arrow_init():
	arrow = load("res://Assets/Projectiles/Arrow/IronArrow/IronArrow.tscn").instance()

func bow_init():
	#max_range_distance = weapon_master.strength * 3 + clamp((5 - arrow.weight) * 20, 5, 80)
	
	ani = $AnimatedSprite
	idle_frames_count = ani.frames.get_frame_count("idle")
	shoot_frames_count = ani.frames.get_frame_count("shoot")
	release_frames_count = ani.frames.get_frame_count("release")
	
	time_ready_to_max_shoot = 0.5
	time_of_every_shoot_frame = time_ready_to_max_shoot / shoot_frames_count
	
	time_to_fully_release = 0.2
	time_of_every_release_frame = time_to_fully_release / release_frames_count
	
	timer_pull_string = Timer.new()
	timer_pull_string.one_shot = true
	add_child(timer_pull_string)

func _update_animation():
	pass

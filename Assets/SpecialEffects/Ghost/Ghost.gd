extends Particles2D

var myself
var towards
var ani
var spr
var is_ani
var body_transform
var is_ghost_visible

func _ready():
	myself = get_parent()
	_ghost_init()

func _physics_process(delta):
	_update_ghost()

func _update_ghost():
	towards = myself.towards
	if towards == "right":
		if is_ani:#如果拥有动画精灵
			self.texture = ani.frames.get_frame("horizon", ani.frame)
			self.scale.x = 1
			return
	if towards == "left":
		if is_ani:
			self.texture = ani.frames.get_frame("horizon", ani.frame)
			self.scale.x = -1#水平翻转
			return
	if !is_ani:#如果不拥有动画精灵（即 拥有sprite节点）
		self.texture = spr.texture
		self.scale.x = 1

func _ghost_init():
	towards = myself.towards
	ani = myself.ani
	spr = myself.spr
	is_ani = myself.is_ani
	body_transform = myself.body_transform
	is_ghost_visible = myself.is_ghost_visible
	if is_ani:#如果拥有动画节点
		self.texture = ani.frames.get_frame("horizon", ani.frame)#初始化 残影材质为动画节点ani的当前帧的材质
	else:
		self.texture = spr.texture
	self.global_position += body_transform#残影位置更新为全局position
	self.visible = true
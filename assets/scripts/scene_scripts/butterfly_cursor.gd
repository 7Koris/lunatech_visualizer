extends MeshInstance3D

@onready var trail = $GPUTrail3D

var colors = [
	Color.RED,
	Color.BLUE,
	Color.GREEN,
	Color.ORANGE,
	Color.YELLOW,
	Color.PURPLE,
]
var ramp: GradientTexture1D
func _ready() -> void:
	self.position.x += randf() * 10
	ramp = trail.color_ramp
	var idx = int(randf() * len(colors))
	ramp.gradient.set_color(0, Color.from_rgba8(randi() % 255, randi() % 255, randi() % 255))

	
var sigma = 10
var r = 24.74
var b = 8/3

var time_scale = 0.5
var time_elapsed = 0.0
func _physics_process(delta: float) -> void:
	time_elapsed += delta * OscClient.flux / 10
	time_scale = 1 * OscClient.low_range_rms * 1
	
	var newx = self.position.x
	var newy = self.position.y
	var newz = self.position.z
	newx += (sigma*(self.position.y-self.position.x)) * delta * time_scale
	newy += ((r*self.position.x)-self.position.y-(self.position.x*self.position.z)) * delta * time_scale
	newz += ((self.position.x*self.position.y)-(b*self.position.z)) * delta * time_scale
	self.position = Vector3(newx, newy, newz)
	
	var r = sin(time_elapsed) * 0.5 + 0.5
	var g = sin(time_elapsed + PI / 3) * 0.5 + 0.5
	var b = sin(time_elapsed + 2 * PI / 3) * 0.5 + 0.5
	ramp.gradient.set_color(0, Color(r, g, b))
	

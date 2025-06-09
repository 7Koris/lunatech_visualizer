extends Control

@onready var sprite2d = $CenterContainer/Control
@onready var colorrect = $ColorRect
@onready var c2 = $ColorRect2
var sum = 0
func _process(delta: float) -> void:
	sprite2d.rotation += delta * OscClient.zcr * 50
	colorrect.material.set("shader_parameter/shake_power", OscClient.mid * delta * 2)#floor())
	colorrect.material.set("shader_parameter/mu", OscClient.mid * delta * 1000)

	sum += delta + OscClient.bass * delta * 20
	c2.material.set("shader_parameter/iTime", sum)
	c2.material.set("shader_parameter/mu", OscClient.bass * delta * 100)

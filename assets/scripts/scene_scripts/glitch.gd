extends Control

@onready var sprite2d = $CenterContainer/Control
@onready var colorrect = $ColorRect
@onready var c2 = $ColorRect2
var sum = 0
func _process(delta: float) -> void:
	sprite2d.rotation += delta * OscClient.zcr * 50
	colorrect.material.set("shader_parameter/shake_power", floor(OscClient.bass * delta * 100))
	colorrect.material.set("shader_parameter/mu", floor(OscClient.bass * delta * 10000))

	sum += delta + OscClient.bass * delta * 50
	c2.material.set("shader_parameter/iTime", sum)
	c2.material.set("shader_parameter/mu", OscClient.bass * 10)

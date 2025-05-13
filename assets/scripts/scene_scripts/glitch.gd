extends Control

@onready var sprite2d = $CenterContainer/Control
@onready var colorrect = $ColorRect
@onready var c2 = $ColorRect2
var sum = 0
func _process(delta: float) -> void:
	#sprite2d.rotation += 0.1 * delta * 100 * OscClient.high_range_rms * 50
	sprite2d.rotation += 0.1 * delta * OscClient.zcr * 100
	colorrect.material.set("shader_parameter/shake_power", (OscClient.high_range_rms) / 2)
	colorrect.material.set("shader_parameter/mu", (OscClient.high_range_rms) * 1000/2)
	#sum += delta + OscClient.flux * delta * 100 * 10
	sum += delta +  OscClient.low_range_rms * OscClient.flux * delta * 0.01 * 10
	c2.material.set("shader_parameter/iTime", sum)
	c2.material.set("shader_parameter/mu", OscClient.zcr * OscClient.flux * 10)

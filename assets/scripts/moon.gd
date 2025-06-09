extends Node3D

@onready var wire_layer = $WireLayer
@onready var scan_layer = $ScanLayer

var spin_time = 0
var ring_time = 0
var ring_sum = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	spin_time += OscClient.rms * delta * 250 * OscClient.zcr
	ring_time = spin_time
	ring_sum += OscClient.bass * delta * 10

	wire_layer.material_override.set("shader_parameter/time", spin_time)
	scan_layer.material_override.set("shader_parameter/time", ring_time)

	scan_layer.material_override.set("shader_parameter/ring_mult", ring_sum)

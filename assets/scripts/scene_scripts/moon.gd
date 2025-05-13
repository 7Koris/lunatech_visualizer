extends Node3D

@onready var wire_layer = $WireLayer
@onready var scan_layer = $ScanLayer

var spin_time = 0
var ring_time = 0
var ring_sum = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	spin_time += OscClient.flux * 0.1 * delta
	ring_time = spin_time
	ring_sum += OscClient.low_range_rms * delta * 20

	wire_layer.material_override.set("shader_parameter/time", spin_time)
	scan_layer.material_override.set("shader_parameter/time", ring_time)

	scan_layer.material_override.set("shader_parameter/ring_mult", ring_sum)

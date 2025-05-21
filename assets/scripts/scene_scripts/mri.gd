extends Node3D

@onready var dna = $dna
@onready var head = $CanvasLayer/head_anchor/head
@onready var env = $WorldEnvironment.environment
@onready var dna_children = dna.get_children()
@onready var brain_slices = $CanvasLayer/head_anchor/head/brain/Sketchfab_Scene/Sketchfab_model/Geode.get_children()

var color_mult = 1
var shake = 0
func _process(delta: float) -> void:
	color_mult = OscClient.low_range_rms * 20
	shake = OscClient.high_range_rms * 10
	env.ambient_light_color = Color(color_mult, 0, clampf(1 / (color_mult + 0.001), -10, 5))
	
	for child: MeshInstance3D in dna_children:
		child.get_surface_override_material(0).set("shader_parameter/shake_power", shake * 0)
		child.get_surface_override_material(0).set("shader_parameter/offset", shake * 0.01)
		# (delta * OscClient.zcr + delta * 0.1
	dna.rotate_y(-delta * OscClient.high_range_rms * 100 - delta * 0.1)
	head.rotate_y(delta * OscClient.zcr * 5 + delta * 0.001)
	
	for i in range(1, len(brain_slices)):
		#var target = len(brain_slices)
		#target *= OscClient.zcr
		brain_slices[i].visible = true #(i < target)

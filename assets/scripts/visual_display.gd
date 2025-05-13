extends SubViewportContainer

class_name VisualDisplay

@onready var post_process_layer = self
@onready var scene_layer = $SceneLayer
@onready var main_gui = $MainGui
@onready var hint = $Label

func _ready() -> void:
	main_gui.visual_display_instance = self
	main_gui.start()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("hide_hint"):
		hint.visible = !hint.visible

@tool
extends CollisionShape3D

@export var enable_visuals = false
var visuals_active = false
var visual_node : CSGBox3D

func _ready():
	if not Engine.is_editor_hint() and visual_node != null:
		visual_node.queue_free()
		visual_node = null

func _process(delta):
	if (Engine.is_editor_hint() and enable_visuals != visuals_active):
		update_visuals()
	
func update_visuals():
	if (enable_visuals and visual_node == null):
		visuals_active = true
		visual_node = CSGBox3D.new()
		add_child(visual_node)
		visual_node.size = shape.size
	else:
		if visual_node != null:
			visual_node.queue_free()
			visual_node = null
		visuals_active = false

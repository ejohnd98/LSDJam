extends Node3D

var mesh_instances = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is MeshInstance3D:
			mesh_instances.append(child)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func set_emission_color (color : Color):
	for mesh_obj in mesh_instances:
		var mesh_3d : MeshInstance3D = mesh_obj
		var material : Material = mesh_3d.get_active_material(0)
		material.emission = color

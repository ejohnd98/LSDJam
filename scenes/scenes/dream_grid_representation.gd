extends Node3D

@onready var render_quad : MeshInstance3D = $RenderQuad
@onready var hide_mesh = false

func _ready():
	DreamGridViewer.on_grid_updated.connect(update_texture)

func update_texture():
	await get_tree().process_frame
	render_quad.get_surface_override_material(0).albedo_texture = DreamGridViewer.get_dream_grid_texture()

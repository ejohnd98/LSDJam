extends Panel

@onready var player_node = $"../../SubViewport/Game/Player"
@onready var compass_node = $TextureRect


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$TextureRect.rotation = player_node.get_player_rotation()

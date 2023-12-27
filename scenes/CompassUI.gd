extends Control

@onready var player_node = $"../../SubViewport/Player"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Needle.rotation = player_node.get_player_rotation() + PI

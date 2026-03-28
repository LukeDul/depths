extends CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


var player_buffer = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	player_buffer.push_back(get_parent().get_node("Player").position)
	
	if len(player_buffer) > 50:
		position = player_buffer.pop_front()

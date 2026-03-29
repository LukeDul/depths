extends Area2D

var _activated: bool = false

func _ready() -> void:
	monitoring = false
	monitorable = false
	body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	if not _activated and Globals.chase_active:
		_activated = true
		monitoring = true
		monitorable = true

func _on_body_entered(body: Node2D) -> void:
	if not body is Player: return
	var ending_scene := load("res://endings/ending.tscn") as PackedScene
	var ending := ending_scene.instantiate()
	ending.ending_id = Globals.ending_id   # set by dialogue via do set_ending(n)
	get_tree().root.add_child(ending)
	get_tree().paused = true
	ending.process_mode = Node.PROCESS_MODE_ALWAYS

extends CharacterBody2D

@export var dialogue_resource: DialogueResource
@export var dialogue_scene: int

var has_player = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Bus.player_interacted.connect(_on_interacted)
	
func _on_interacted():
	if has_player:
		DialogueManager.show_dialogue_balloon(dialogue_resource, "start")

func _on_area_2d_area_entered(_area: Area2D) -> void:
	has_player = true 
	print("has player!")


func _on_area_2d_area_exited(_area: Area2D) -> void:
	has_player = false

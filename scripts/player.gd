class_name Player extends CharacterBody2D

var movement_disabled = false 

var SPEED = 1000

@onready var interaction_label: Label = %InteractionLabel

@onready var blank_dialogue: DialogueResource = preload("res://dialogue/blank.dialogue")


func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("touch"):
		print("touched!")
		Bus.player_interacted.emit()


func _physics_process(_delta: float) -> void:
	if Globals.is_player_frozen: return 
	
	var new_vel = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		new_vel.y -= SPEED
	elif Input.is_action_pressed("move_down"):
		new_vel.y += SPEED
	
	if Input.is_action_pressed("move_right"):
		new_vel.x += SPEED
	elif Input.is_action_pressed("move_left"):
		new_vel.x -= SPEED
	
	if new_vel == Vector2.ZERO:
		$AnimatedSprite2D.stop()
	else:
		$AnimatedSprite2D.play()
		
	velocity = new_vel
	
	move_and_slide()


#region Signals
func _on_interaction_area_2d_area_entered(_area: Area2D) -> void:
	interaction_label.show() # assumes every area is interactible


func _on_interaction_area_2d_area_exited(_area: Area2D) -> void:
	interaction_label.hide()
	
	var balloon = get_node_or_null("/root/Main/DiscoBalloon/")
	if balloon: balloon.queue_free()
	else: print("no balloon")
	
func _on_dialogue_started(_resource: DialogueResource):
	print("started dialogue!")


func _on_dialogue_ended(_resource: DialogueResource):
	Globals.is_player_frozen = false 
	print("ended dialogue!")
#endregion

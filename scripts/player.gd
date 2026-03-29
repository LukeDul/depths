class_name Player extends CharacterBody2D

var SPEED = 1000
var last_direction := "down"
var nudge_resource: DialogueResource

@onready var interaction_label: Label = %InteractionLabel
@onready var nudge_button: Button = %NudgeButton

var hasMirror := false:
	set(v): 
		if v: $Button.visible = true 
		else: $Button.visible = false 

var hairColor = 0 # 0-6 

#region Defaults
func _ready() -> void:
	interaction_label.hide()
	nudge_button.hide()
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	Bus.nudged.connect(_on_nudged)
	Bus.unnudged.connect(_on_unnudged)
	Bus.disco_available.connect(_on_disco_available)
	Bus.disco_unavailable.connect(_on_disco_unavailable)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("touch"):
		Bus.player_interacted.emit()

func _on_dialogue_started(_resource) -> void:
	Globals.is_player_frozen = true
	$AnimatedSprite2D.pause()

func _on_dialogue_ended(_resource) -> void:
	Globals.is_player_frozen = false
	$AnimatedSprite2D.play()


func _physics_process(_delta: float) -> void:
	if Globals.is_player_frozen: return 
	
	var new_vel = Vector2.ZERO
	var target_anim := "idle_" + last_direction

	if Input.is_action_pressed("move_up"):
		new_vel.y -= SPEED
		last_direction = "up"
		target_anim = "walk_up"
	elif Input.is_action_pressed("move_down"):
		new_vel.y += SPEED
		last_direction = "down"
		target_anim = "walk_down"
	if Input.is_action_pressed("move_right"):
		new_vel.x += SPEED
		last_direction = "right"
		target_anim = "walk_right"
	elif Input.is_action_pressed("move_left"):
		new_vel.x -= SPEED
		last_direction = "left"
		target_anim = "walk_left"

	if $AnimatedSprite2D.animation != target_anim:
		$AnimatedSprite2D.play(target_anim)

	velocity = new_vel
	
	move_and_slide()
#endregion


#region Signals
#func _on_dialogue_started(_resource: DialogueResource):
	#print("started dialogue!")
#
#
#func _on_dialogue_ended(_resource: DialogueResource):
	#Globals.is_player_frozen = false 
	#print("ended dialogue!")


func _on_nudge_button_pressed() -> void:
	if nudge_button.get_child_count() == 0:
		nudge_start()
	else:
		nudge_button.get_child(0).queue_free()
	
	
func _on_nudged(dialogue_resource) -> void:
	nudge_resource = dialogue_resource
	nudge_button.show()
	
func _on_unnudged() -> void:
	nudge_button.hide()
	if nudge_button.get_child_count() == 1:
		nudge_button.get_child(0).queue_free()
	elif nudge_button.get_child_count() > 1:
		push_error("nudge_button should only have one child or none. has %s" % nudge_button.get_child_count())

func _on_disco_available(verb: String) -> void:
	interaction_label.show()
	interaction_label.text = verb

func _on_disco_unavailable() -> void:
	interaction_label.hide()
	var balloon = get_node_or_null("/root/Main/DiscoBalloon/")
	if balloon: balloon.queue_free()
#endregion


#region Helpers
func nudge_start():
	var balloon_path: String = "res://nudge_balloon/nudge_balloon.tscn"
	var balloon_scene 
	if not ResourceLoader.exists(balloon_path):
		push_error("wrong nudge balloon path ")
	
	if balloon_path is String:
		balloon_scene = load(balloon_path)

	var balloon: Control = balloon_scene.instantiate()
	
	nudge_button.add_child(balloon)

	if balloon.has_method(&"start"):
		balloon.start(nudge_resource, "", [])
	elif balloon.has_method(&"Start"):
		balloon.Start(nudge_resource, "", [])
	else:
		assert(false, DMConstants.translate(&"runtime.dialogue_balloon_missing_start_method"))

	DialogueManager.dialogue_started.emit(nudge_resource)
	DialogueManager.bridge_dialogue_started.emit(nudge_resource)
#endregion


func _on_button_pressed() -> void:
	$Mirror.visible = !$Mirror.visible
	

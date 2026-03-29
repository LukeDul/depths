extends CharacterBody2D

@export var nudge_resource: DialogueResource
@export var dialogue_resource: DialogueResource
@export var disappears_after_dialogue: bool = false  ## warp + dissolve after dialogue ends

var has_player: bool = false

func _ready() -> void:
	Bus.player_interacted.connect(_on_interacted)

func _on_interacted() -> void:
	if not has_player: return
	if disappears_after_dialogue:
		DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
		await DialogueManager.dialogue_ended
		_play_dissolve()
	else:
		DialogueManager.show_dialogue_balloon(dialogue_resource, "start")

func _play_dissolve() -> void:
	var sprite: Node = get_node_or_null("Sprite2D")
	if not sprite: return

	# Apply dissolve shader to the sprite
	var shader := load("res://npc_dissolve.gdshader") as Shader
	if not shader: return
	var mat := ShaderMaterial.new()
	mat.shader = shader
	sprite.material = mat

	# Tween: first ramp up distortion, then dissolve out
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_method(func(v: float): mat.set_shader_parameter("distort_strength", v), 0.0, 0.15, 0.5)
	tween.tween_method(func(v: float): mat.set_shader_parameter("dissolve", v), 0.0, 1.0, 0.8)
	await tween.finished
	queue_free()

func _on_area_2d_area_entered(_area: Area2D) -> void:
	has_player = true
	if nudge_resource:
		Bus.nudged.emit(nudge_resource)
	if dialogue_resource:
		Bus.disco_available.emit("Talk?")

func _on_area_2d_area_exited(_area: Area2D) -> void:
	has_player = false
	if nudge_resource:
		Bus.unnudged.emit()
	if dialogue_resource:
		Bus.disco_unavailable.emit()

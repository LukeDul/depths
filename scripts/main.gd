extends Node2D

@export var dialogue_resource: DialogueResource
@export var hit_sound: AudioStream          ## drag in an AudioStream asset
@export var hit_grain_boost: float = 0.5   ## how much to add to static_strength on hit
@export var hit_grain_duration: float = 0.6 ## seconds to decay back to baseline

var _static_mat: ShaderMaterial = null
var _grain_timer: float = 0.0
var _grain_baseline: float = 0.10

var _hit_sfx: AudioStreamPlayer = null

func _ready() -> void:
	_build_static_overlay()
	Bus.player_hit.connect(_on_player_hit)
	_hit_sfx = AudioStreamPlayer.new()
	add_child(_hit_sfx)

func give_mirror() -> void:
	var player := get_node_or_null("Player") as Player
	if player:
		player.hasMirror = true

func set_ending(id: int) -> void:
	Globals.ending_id = id

func _process(delta: float) -> void:
	if _grain_timer > 0.0 and _static_mat:
		_grain_timer -= delta
		var t = clamp(_grain_timer / hit_grain_duration, 0.0, 1.0)
		_static_mat.set_shader_parameter("static_strength", _grain_baseline + hit_grain_boost * t)
		if _grain_timer <= 0.0:
			_static_mat.set_shader_parameter("static_strength", _grain_baseline)

func _on_player_hit() -> void:
	_grain_timer = hit_grain_duration
	if is_instance_valid(_hit_sfx) and hit_sound:
		_hit_sfx.stream = hit_sound
		_hit_sfx.play()

func _build_static_overlay() -> void:
	var shader := load("res://screen_static.gdshader") as Shader
	if not shader: return
	_static_mat = ShaderMaterial.new()
	_static_mat.shader = shader
	var canvas := CanvasLayer.new()
	canvas.layer = 101
	add_child(canvas)
	var rect := ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.material = _static_mat
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(rect)

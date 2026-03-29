extends CharacterBody2D

enum Mode { CHASE, LEAD }

@export var mode: Mode = Mode.CHASE
@export var chase_speed: float = 180.0       ## pixels per second
@export var stop_delay: float = 5.0          ## seconds stopped before shadow attacks (CHASE)
@export var waypoints: Array[Node2D] = []    ## ordered list of Marker2D / Node2D targets
@export var sight_range: float = 120.0       ## distance at which shadow flees to next waypoint
@export var chase_dialogue: DialogueResource ## dialogue to play before triggering chase at last waypoint

var is_chasing := false
var player_buffer = []
var last_direction := "down"
var stop_timer := 0.0

# LEAD mode state
var waypoint_index := 0
var _fleeing := false             # true while actively moving to next waypoint
var _dialogue_triggered := false  # true once the pre-chase dialogue has fired
var _waiting_for_move := false    # true after dialogue ends, until player moves

# Effects
var _distortion_rect: ColorRect
var _shake_timer := 0.0
var _shake_strength := 0.0
@export var shake_duration: float = 0.4
@export var shake_strength: float = 8.0


func _ready() -> void:
	$Area2D.body_entered.connect(_on_area_body_entered)
	if mode == Mode.LEAD and waypoints.size() > 0:
		call_deferred("_snap_to_first_waypoint")
	_build_distortion_overlay()

func _build_distortion_overlay() -> void:
	var shader := load("res://screen_distortion.gdshader") as Shader
	if not shader: return
	var mat := ShaderMaterial.new()
	mat.shader = shader
	var canvas := CanvasLayer.new()
	canvas.layer = 50
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas)
	_distortion_rect = ColorRect.new()
	_distortion_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_distortion_rect.material = mat
	_distortion_rect.visible = false
	_distortion_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_distortion_rect.process_mode = Node.PROCESS_MODE_ALWAYS
	canvas.add_child(_distortion_rect)

func _snap_to_first_waypoint() -> void:
	global_position = waypoints[0].global_position

func _on_area_body_entered(body: Node2D) -> void:
	if not body is Player: return
	var mirror: AnimatedSprite2D = body.get_node_or_null("Mirror/Face")
	if mirror:
		mirror.frame = (mirror.frame + 1) % mirror.sprite_frames.get_frame_count(mirror.animation)
	Bus.player_hit.emit()
	# Camera shake
	_shake_timer = shake_duration
	_shake_strength = shake_strength


func _physics_process(delta: float) -> void:
	var player: CharacterBody2D = get_parent().get_node("Player")
	var player_sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	var shadow_sprite: AnimatedSprite2D = $AnimatedSprite2D

	# Camera shake tick
	if _shake_timer > 0.0:
		_shake_timer -= delta
		var cam: Camera2D = player.get_node_or_null("Camera2D")
		if cam:
			var t := _shake_timer / shake_duration
			cam.offset = Vector2(
				randf_range(-1.0, 1.0) * _shake_strength * t,
				randf_range(-1.0, 1.0) * _shake_strength * t
			)
		if _shake_timer <= 0.0:
			var cam2: Camera2D = player.get_node_or_null("Camera2D")
			if cam2: cam2.offset = Vector2.ZERO

	match mode:
		Mode.CHASE:
			_process_chase(delta, player, player_sprite, shadow_sprite)
		Mode.LEAD:
			_process_lead(delta, player, shadow_sprite)


# ── CHASE ────────────────────────────────────────────────────────────────────

func _process_chase(delta: float, player: CharacterBody2D,
		player_sprite: AnimatedSprite2D, shadow_sprite: AnimatedSprite2D) -> void:

	# After dialogue: hold still until the player takes a step
	if _waiting_for_move:
		if player.velocity != Vector2.ZERO:
			_waiting_for_move = false
			is_chasing = true
			stop_timer = 0.0
		return

	if player.velocity == Vector2.ZERO:
		stop_timer += delta
	else:
		stop_timer = 0.0

	if not is_chasing: return

	if stop_timer >= stop_delay:
		player_buffer.clear()
		position = position.move_toward(player.position, chase_speed * delta)
		var idle_anim = "idle_" + last_direction
		if shadow_sprite.animation != idle_anim:
			shadow_sprite.play(idle_anim)
	else:
		player_buffer.push_back({
			"pos": player.position,
			"anim": player_sprite.animation
		})
		if len(player_buffer) > 50:
			var frame = player_buffer.pop_front()
			position = frame.pos
			if shadow_sprite.animation != frame.anim:
				shadow_sprite.play(frame.anim)
			last_direction = frame.anim.split("_")[-1]


# ── LEAD ─────────────────────────────────────────────────────────────────────

func _process_lead(delta: float, player: CharacterBody2D,
		shadow_sprite: AnimatedSprite2D) -> void:

	if waypoints.is_empty(): return

	var target: Node2D = waypoints[waypoint_index]

	if _fleeing:
		# Move toward the current waypoint
		global_position = global_position.move_toward(target.global_position, chase_speed * delta)
		_update_lead_anim(shadow_sprite, target.global_position)

		# Arrived?
		if global_position.distance_to(target.global_position) < 4.0:
			# Check if this waypoint requires waiting for the player
			var should_wait: bool = target.get_meta("wait", true)
			if should_wait:
				_fleeing = false  # enter wait state
			else:
				# Pass-through: immediately advance to next waypoint
				waypoint_index = min(waypoint_index + 1, waypoints.size() - 1)
				# _fleeing stays true, keep moving

	else:
		# Idle at waypoint — wait for player to enter sight range
		var idle_anim = "idle_" + last_direction
		if shadow_sprite.animation != idle_anim:
			shadow_sprite.play(idle_anim)

		var dist = global_position.distance_to(player.global_position)
		if dist <= sight_range:
			var at_last = waypoint_index >= waypoints.size() - 1
			if at_last:
				if not _dialogue_triggered:
					_dialogue_triggered = true
					if is_instance_valid(chase_dialogue):
						# Play dialogue, then start chase when it ends
						DialogueManager.dialogue_ended.connect(_begin_chase, CONNECT_ONE_SHOT)
						DialogueManager.show_dialogue_balloon(chase_dialogue, "start")
					else:
						_begin_chase(null)
			else:
				# Advance to next waypoint
				waypoint_index += 1
				_fleeing = true


func _update_lead_anim(shadow_sprite: AnimatedSprite2D, target: Vector2) -> void:
	var dir = (target - global_position).normalized()
	var anim: String
	if abs(dir.x) > abs(dir.y):
		anim = "walk_right" if dir.x > 0 else "walk_left"
		last_direction = "right" if dir.x > 0 else "left"
	else:
		anim = "walk_down" if dir.y > 0 else "walk_up"
		last_direction = "down" if dir.y > 0 else "up"

	if shadow_sprite.animation != anim:
		shadow_sprite.play(anim)


func _begin_chase(_resource) -> void:
	mode = Mode.CHASE
	_waiting_for_move = true
	Globals.chase_active = true
	if _distortion_rect:
		_distortion_rect.visible = true

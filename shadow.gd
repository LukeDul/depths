extends CharacterBody2D

var player_buffer = []
var last_direction := "down"
var stop_timer := 0.0

@export var chase_speed: float = 180.0        ## pixels per second
@export var stop_delay: float = 0.25          ## seconds stopped before shadow attacks

func _physics_process(delta: float) -> void:
	var player: CharacterBody2D = get_parent().get_node("Player")
	var player_sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	var shadow_sprite: AnimatedSprite2D = $AnimatedSprite2D

	if player.velocity == Vector2.ZERO:
		stop_timer += delta
	else:
		stop_timer = 0.0

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
			# Extract direction from anim name e.g. "walk_up" -> "up"
			last_direction = frame.anim.split("_")[-1]

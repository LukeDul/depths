shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float strength: hint_range(0.0, 0.05) = 0.012;
uniform float speed: hint_range(0.0, 10.0) = 3.0;
uniform float frequency: hint_range(0.0, 30.0) = 12.0;
uniform float aberration: hint_range(0.0, 0.02) = 0.005;

void fragment() {
	vec2 uv = SCREEN_UV;
	float t = TIME * speed;

	// Wave warp
	uv.x += sin(uv.y * frequency + t) * strength;
	uv.y += cos(uv.x * frequency + t * 0.8) * strength;

	// Chromatic aberration
	float r = texture(SCREEN_TEXTURE, uv + vec2(aberration, 0.0)).r;
	float g = texture(SCREEN_TEXTURE, uv).g;
	float b = texture(SCREEN_TEXTURE, uv - vec2(aberration, 0.0)).b;

	COLOR = vec4(r, g, b, 1.0);
}

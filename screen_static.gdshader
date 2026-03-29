shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

uniform float darkness : hint_range(0.0, 1.0) = 0.18;       // how much to darken
uniform float static_strength : hint_range(0.0, 1.0) = 0.2; // grain intensity
uniform float static_speed : hint_range(0.0, 60.0) = 15.0;   // how fast static changes

// simple hash noise
float hash(vec2 p) {
	p = fract(p * vec2(234.34, 435.345));
	p += dot(p, p + 34.23);
	return fract(p.x * p.y);
}

void fragment() {
	vec4 screen = texture(SCREEN_TEXTURE, SCREEN_UV);

	// Darkening
	screen.rgb *= (1.0 - darkness);

	// Animated grain / static
	float t = floor(TIME * static_speed);
	float grain = hash(SCREEN_UV + vec2(t * 0.1, t * 0.7));
	// bias grain so it looks like noise bursts rather than uniform fog
	grain = pow(grain, 3.0) * static_strength;

	screen.rgb += vec3(grain);

	COLOR = screen;
}

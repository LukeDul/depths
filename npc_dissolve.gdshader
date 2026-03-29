shader_type canvas_item;

uniform float distort_strength : hint_range(0.0, 0.3) = 0.0;
uniform float dissolve : hint_range(0.0, 1.0) = 0.0;

float hash(vec2 p) {
	p = fract(p * vec2(234.34, 435.345));
	p += dot(p, p + 34.23);
	return fract(p.x * p.y);
}

void fragment() {
	vec2 uv = UV;

	// Warp UVs
	float t = TIME * 8.0;
	uv.x += sin(uv.y * 12.0 + t) * distort_strength;
	uv.y += cos(uv.x * 10.0 + t * 0.9) * distort_strength;

	vec4 col = texture(TEXTURE, uv);

	// Noise-based dissolve: discard pixels below threshold
	float noise = hash(UV + vec2(dissolve * 3.7, dissolve * 1.3));
	col.a *= step(dissolve, noise);

	COLOR = col;
}

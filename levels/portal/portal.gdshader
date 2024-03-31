shader_type spatial;
render_mode unshaded;

uniform sampler2D caustics_texture : hint_default_black;
uniform sampler2D color_gradient : source_color;
uniform sampler2D distort_noise : hint_default_black;

uniform float flow_speed = 0.3;
uniform float vignette_size = 0.3;
uniform float vignette_blend = 0.1;
uniform float distort_strength = 0.1;
uniform float transparency = 0.5;


vec2 polar_coordinates(vec2 uv, vec2 center, float zoom, float repeat)
{
	vec2 dir = uv - center;
	highp float radius = length(dir) * 2.0;
	highp float angle = atan(dir.y, dir.x) / TAU;
	return mod(vec2(radius * zoom, angle * repeat), 1.0);
}

void vertex()
{
	float dn = texture(distort_noise, UV + TIME * 0.1).r;
	VERTEX.y += dn * 0.1;
}

void fragment()
{
	// Polar UVs + Noise for caustics
	vec2 base_uv = UV;
	float dn = texture(distort_noise, UV + TIME * 0.1).r;
	base_uv += dn * distort_strength;
	base_uv -= distort_strength / 2.0;
	highp vec2 polar_uv = polar_coordinates(base_uv, vec2(0.5), 1.0, 1.0);
	polar_uv.x -= TIME * flow_speed;
	float caus = texture(caustics_texture, polar_uv).r;
	
	// Fade out caustics
	float cd = distance(UV, vec2(0.5));
	float vign = 1.0 - smoothstep(vignette_size, vignette_size + vignette_blend, cd);
	
	// Color the caustics
	float grad_uv = caus * vign;
	vec3 color = texture(color_gradient, vec2(grad_uv)).rgb;
	
	ALBEDO = color;
	ALPHA = transparency;
}
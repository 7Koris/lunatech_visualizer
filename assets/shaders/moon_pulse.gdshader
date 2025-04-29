shader_type spatial;
render_mode unshaded;

uniform sampler2D _a;
uniform sampler2D heightmap;
uniform float height_ratio = 2.0;
uniform float start = 0;
uniform float end = 0.1;

vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

void vertex() {
	vec2 uv_range = vec2(end, end) - vec2(start, start);
    vec2 adjusted_uv = vec2(start, start) + uv_range * UV;
	adjusted_uv = rotate(adjusted_uv, vec2((start + end) / 2.0), TIME * 0.1f);
	VERTEX.y += texture(heightmap, adjusted_uv).r * height_ratio;
}

uniform vec3 ring_color: source_color = vec3(1.0);
uniform float ring_frequency = 50.0;
/** Portion of the visible rings. Negative values give wider rings, positive values give narrower rings*/
uniform float ring_portion = 1000.0;
/** Negative values move the rings outwards, positive value move the rings inwards */
uniform float move_speed = -10.0;
uniform bool smooth_edge = false;

void fragment() {
	vec2 uv_range = vec2(end, end) - vec2(start, start);
    vec2 adjusted_uv = vec2(start, start) + uv_range * UV;

	float dist = distance(UV, vec2(0.5,0.5));
	float rings = tan(dist * ring_frequency + (TIME * 0.05 * move_speed));
	rings = step(ring_portion, rings);
	float blend_alpha = smoothstep(0.5, 0.4, dist);
	if (dist > 2. || rings < 1.){
		ALPHA = 0.0;
	}
	else if (rings > 0.0){
		ALPHA = smooth_edge ? blend_alpha : 1.0;
	}

	ALBEDO = texture(_a, adjusted_uv).rgb;
}

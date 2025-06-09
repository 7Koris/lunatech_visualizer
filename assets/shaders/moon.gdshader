shader_type spatial;
render_mode wireframe;

uniform sampler2D _a;
uniform sampler2D heightmap;
uniform float height_ratio = 2.0;
uniform float start = 0;
uniform float end = 0.1;

uniform float ox = 0;
uniform float oy = 0.;
uniform float spin_speed = 0.;
uniform float time = 0.;

uniform vec4 color : source_color;



uniform vec4 custom_color : source_color;

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
	adjusted_uv = rotate(adjusted_uv, vec2((start + end) / 2.0), time * 0.1f * spin_speed);
	adjusted_uv = adjusted_uv + vec2(ox, oy);
	VERTEX.y += texture(heightmap, adjusted_uv).r * height_ratio;
	POINT_SIZE = 1.;
}

void fragment() {
	vec2 uv_range = vec2(end, end) - vec2(start, start);
    vec2 adjusted_uv = vec2(start, start) + uv_range * UV;
	adjusted_uv = rotate(adjusted_uv, vec2((start + end) / 2.0), time * 0.1f * spin_speed);
	adjusted_uv = adjusted_uv + vec2(ox, oy);

   // vec4 tex_color = texture(texture_albedo, UV);

    // Mix the texture color with the custom color
    //vec3 mixed_color = mix(tex_color.rgb, custom_color, mix_strength);
	ALBEDO = texture(_a, adjusted_uv).rgb + 0.05;
}

shader_type spatial;

uniform float offset = 0.;

void vertex() {
    VERTEX.x += offset;
}

uniform vec3 color: source_color = vec3(1.0);
uniform sampler2D src_tex;



void fragment() {
	vec4 tex_color = texture(src_tex, UV);

    vec3 mixed_color = mix(tex_color.rgb, color, 0.1);
	ALBEDO = mixed_color;
}



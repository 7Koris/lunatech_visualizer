shader_type spatial;

uniform sampler2D _a;
uniform sampler2D heightmap;
uniform float height_ratio = 2.0;
uniform float scale = 0.1;

uniform float cx = 0.0;
uniform float cy = 0.0;
uniform float start = 0;
uniform float end = 0.1;

render_mode wireframe;

uniform vec4 modelColor : source_color;
uniform vec4 wireframeColor : source_color;

uniform float width : hint_range(0.0, 15.) = 1.;
uniform float modelOpacity : hint_range(0.0, 1.0) = 1.;

uniform bool filtered = false;

const vec3 vectors[3] = {
	vec3(1.0, 0.0 ,0.0),
	vec3(0.0, 1.0 ,0.0),
	vec3(0.0, 0.0 ,1.0)
};

varying vec3 baryCoord;

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

	baryCoord = vectors[VERTEX_ID % 3];
	
	vec2 uv_range = vec2(end, end) - vec2(start, start);
    vec2 adjusted_uv = vec2(start, start) + uv_range * UV;
	adjusted_uv = rotate(adjusted_uv, vec2((start + end) / 2.0), TIME * 0.1f);
	VERTEX.y += texture(heightmap, adjusted_uv).r * height_ratio;
}

void fragment() {
	//vec2 uv_range = vec2(end, end) - vec2(start, start);
    //vec2 adjusted_uv = vec2(start, start) + uv_range * UV; // Remap UVs to the subsection
	//adjusted_uv = rotate(adjusted_uv, vec2((start + end) / 2.0), TIME * 0.1f);
	//ALBEDO = texture(_a, adjusted_uv).rgb;
	
	vec3 dBaryCoordX = dFdx(baryCoord);
	vec3 dBaryCoordY = dFdy(baryCoord);
	vec3 dBaryCoord  = sqrt(dBaryCoordX*dBaryCoordX + dBaryCoordY*dBaryCoordY);

	vec3 remap = smoothstep(
		vec3(0.0),
		dBaryCoord * width,
		baryCoord
	);
	
	remap = filtered ? remap : step(.5, remap);

	float closestEdge = min(min(remap.x, remap.y), remap.z);

	ALBEDO = mix(wireframeColor, modelColor, closestEdge).xyz;
	ALPHA = mix(1., modelOpacity, closestEdge);
}

shader_type canvas_item;

//made by xhaya 

uniform sampler2D starNoise: repeat_enable;
uniform sampler2D tintNoise: repeat_enable;
uniform float brightness = 2.0;
uniform float amount = 0.75;
/** so glitchy idk*/
uniform float randomness = 5.785; 
uniform float background_amount: hint_range(0, 1.0 ,0.01) = 0.0; 
/** increasing this so high maxes scrolling effect */
uniform float flashing = 0.001;


void fragment() {
	float noiseTexture = texture(starNoise, VERTEX * randomness + TIME * flashing).r * amount;
	vec4 tintTexture = texture(tintNoise, VERTEX * randomness);
	if (noiseTexture > (background_amount + -noiseTexture)){
		COLOR.rgb = vec3(tintTexture.rgb * pow(noiseTexture, 4)) * brightness;
	} else {
		COLOR.rgb = vec3(0);
	}
	
}
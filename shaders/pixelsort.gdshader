//MADE BY : @ahopness
//LICENSE : CC0
//COMATIBLE WITH : GLES2, GLES3, WEBGL

shader_type canvas_item;

uniform float sort :hint_range(0.0, 2.6)= 0.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment(){
	vec2 uv = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE).xy;
	
	// Pseudo Pixel Sorting
	float sortThreshold = 1.0 - clamp(sort / 2.6, 0.0, 1.0);
	vec2 sortUv = vec2(uv.x, sortThreshold);
	
	// Curved melting transition
	vec2 transitionUV = uv;
	transitionUV.y += pow(sort, 2.0 + (sort * 2.0)) * uv.x * fract(sin(dot(vec2(transitionUV.x), vec2(12.9, 78.2)))* 437.5);
	COLOR = texture(SCREEN_TEXTURE, transitionUV);
	
	// Draw pixel sorting effect behind the melting transition
	if(transitionUV.y > 1.){
		COLOR = texture(SCREEN_TEXTURE, sortUv);
	}else{
		COLOR = texture(SCREEN_TEXTURE, uv);
	}
}
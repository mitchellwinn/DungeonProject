shader_type spatial;
render_mode unshaded;

uniform sampler2D screen : hint_screen_texture;

uniform sampler2DArray _Color_Map;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec3 s = texture(screen, SCREEN_UV).rgb;
	float d = sqrt(dot(s, s));
	vec4 color;
	for (int i=0; i<=4; i++) {
		if (int(floor(d*3.0)) == i) {
			color = texture(_Color_Map, vec3(UV, float(i)));
		}
	}
	
	ALBEDO = color.rgb;
//	ALBEDO = vec3(0.1, 0.3, 0.8);
}

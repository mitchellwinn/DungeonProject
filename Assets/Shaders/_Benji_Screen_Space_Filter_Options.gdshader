shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D depth_texture : hint_depth_texture;

void vertex() {
//	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec4 screen = texture(screen_texture, SCREEN_UV);
	float depth = texture(depth_texture, SCREEN_UV).x;

	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	linear_depth = VERTEX.z + linear_depth;
	
	ALBEDO = screen.rgb;
//	NORMAL_MAP = d.rgb;
	float depthx = dFdx(linear_depth);
	float depthy = dFdy(linear_depth);
	NORMAL = vec3(depthx, depthy, 1.0);
//	NORMAL = NORMAL_MAP;
	ALBEDO = vec3(linear_depth);
}

void light() {
	float ldotn = clamp(dot(normalize(LIGHT), normalize(NORMAL)), 0.0, 1.0);
	ldotn *= 2.0;
	ldotn = floor(ldotn);
	ldotn /= 2.0;
	DIFFUSE_LIGHT += ldotn;
}

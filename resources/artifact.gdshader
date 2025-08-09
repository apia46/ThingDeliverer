shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D TEXTURE : filter_nearest;

void fragment() {
	ALBEDO = texture(TEXTURE, FRAGCOORD.xy / 100.0).xyz;
}
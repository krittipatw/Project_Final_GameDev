shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 edge_color : source_color = vec4(0.6, 0.0, 0.0, 1.0);

void fragment() {
	vec2 offset = UV - vec2(0.5);
	float dist = length(offset) * 1.414;      // 0 กลางจอ ... 1 มุมจอ
	float edge = smoothstep(0.35, 1.0, dist);
	COLOR = vec4(edge_color.rgb, edge * intensity);
}
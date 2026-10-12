shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	float t = mod(floor(TIME * 24.0), 1000.0);          // เปลี่ยนลายทุก ~1/24 วินาที
	vec2 cell = floor(UV * vec2(360.0, 200.0));         // ขนาดเม็ดสัญญาณ
	float noise = hash21(cell + vec2(t * 17.0, t * 3.0));

	// แถบแนวนอนที่วูบผ่านจอ (เด่นขึ้นเมื่อ intensity สูง)
	float row = floor(UV.y * 36.0);
	float band = step(0.96 - intensity * 0.12, hash21(vec2(row, t)));

	float alpha = intensity * (0.2 + 0.6 * noise) + band * intensity * 0.35;
	COLOR = vec4(vec3(noise), clamp(alpha, 0.0, 0.92));
}
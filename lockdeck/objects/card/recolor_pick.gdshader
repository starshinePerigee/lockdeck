shader_type canvas_item;

uniform vec4 new:source_color;
uniform vec4 old:source_color;
uniform vec4 base:source_color = vec4(0.106, 0.102, 0.169, 1);

void fragment() {
    vec4 current_pixel = texture(TEXTURE, UV);
	if (current_pixel.a < 0.05) {
		COLOR = vec4(0, 0, 0, 0);
	}
	else if (distance(current_pixel, old) < 0.20) {
		COLOR = new;
	}
	else {
		COLOR = base;
	}
}
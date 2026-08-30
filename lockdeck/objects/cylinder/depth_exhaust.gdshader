shader_type canvas_item;

instance uniform bool exhaust;
uniform vec4 bg:source_color;
uniform vec4 skip:source_color;
uniform vec4 new_bg:source_color;
uniform vec4 new_fg:source_color;

void fragment() {
    vec4 current_pixel = texture(TEXTURE, UV);
	if (exhaust) {
		if (current_pixel.a < 0.95) {
		} else if (distance(current_pixel, bg) < 0.02) {
			COLOR = new_bg;
		} else if (distance(current_pixel, skip) > 0.02) {
			COLOR = new_fg;
		}
	}
}
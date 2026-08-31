shader_type canvas_item;

instance uniform vec4 new:source_color;
uniform vec4 old:source_color;

void fragment() {
    vec4 current_pixel = texture(TEXTURE, UV);
	if (distance(current_pixel, old) < 0.02) {
		COLOR = new;
	}
}
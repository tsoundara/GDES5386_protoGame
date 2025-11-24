shader_type canvas_item;

uniform float thickness: hint_range(1, 100, 0.1) = 1.0;
uniform float anti_alias = 1.0;
uniform vec4 color: source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform bool outline_enabled = false;

void fragment() {
    vec4 original = texture(TEXTURE, UV);

    // If outline is OFF → draw the sprite normally
    if (!outline_enabled) {
        COLOR = original;
    } 
    else {
        if (original.a > 0.0) {
            COLOR = original;
        } else {
            float max_distance = thickness + anti_alias;
            int max_offset = int(ceil(max_distance));
            bool found_sprite = false;

            for (int i = -max_offset; i <= max_offset; i++) {
                for (int j = -max_offset; j <= max_offset; j++) {
                    vec2 offset = vec2(float(i), float(j));
                    float dist = length(offset);

                    if (dist > max_distance) continue;

                    if (texture(TEXTURE, UV + offset * (TEXTURE_PIXEL_SIZE)).a > 0.0) {
                        found_sprite = true;
                        break;
                    }
                }
                if (found_sprite) break;
            }

            if (found_sprite) {
                COLOR = vec4(1.0, 0.0, 0.0, 1.0);	// Pure red
            } else {
                COLOR = vec4(0.0);
            }
        }
    }
}

shader_type canvas_item;
render_mode blend_mix;

uniform vec2 offset = vec2(8.0, 8.0);
uniform vec4 modulate : source_color;

void fragment() {
    vec4 shadow = vec4(
        modulate.rgb,
        texture(TEXTURE, UV - offset * TEXTURE_PIXEL_SIZE).a * modulate.a
    );
    vec4 col = texture(TEXTURE, UV) * 1.25;

    COLOR = mix(shadow, col, col.a);
}
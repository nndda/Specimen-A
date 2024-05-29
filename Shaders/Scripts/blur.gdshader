shader_type canvas_item;

uniform float lod: hint_range(0, 5) = 0.0;
uniform vec4 color_overlay: source_color = vec4(1, 1, 1, 0);
uniform bool enabled = true;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    if (enabled) {
        vec4 color_b = textureLod(SCREEN_TEXTURE, SCREEN_UV, lod);
        COLOR.rgb = (color_b.rgb * 0.8);
        COLOR.rgba *= color_overlay;
    }
}

shader_type canvas_item;

uniform float lod: hint_range(0, 5) = 0.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 color_b = textureLod(SCREEN_TEXTURE, SCREEN_UV, lod);
    COLOR.rgb = color_b.rgg * 0.8;
}

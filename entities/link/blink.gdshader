shader_type canvas_item;

uniform bool enabled = true ;
uniform float blink_interval = 0.2;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    if (enabled) {
        float phase = mod(TIME, blink_interval * 2.0);
        float visible = step(blink_interval, phase);
        COLOR = tex_color * vec4(1.0, 1.0, 1.0, visible);
    } else {
        COLOR = tex_color;
    }
}
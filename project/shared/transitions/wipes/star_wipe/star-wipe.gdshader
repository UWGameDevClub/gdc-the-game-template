shader_type canvas_item;

uniform vec4 current_screen_color_mask : source_color = vec4(0.0, 0.6, 0.3137, 1.0); 
uniform vec4 transparent_color_mask : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float tolerance : hint_range(0.0, 1.0) = 0.05;

uniform sampler2D current_screen_texture: hint_default_black; 

void fragment() {
    vec4 current_color = texture(TEXTURE, UV);
    
    // Check the distance between the current pixel and the target mask color
    
    if (distance(current_color.rgb, transparent_color_mask.rgb) < tolerance) {
        COLOR = vec4(current_color.rgb, 0.0);
    } else if (distance(current_color.rgb, current_screen_color_mask.rgb) < tolerance) {
		COLOR = texture(current_screen_texture, UV);
	} else {
        COLOR = current_color;
    }
}
shader_type canvas_item;
varying vec4 modulate;

void vertex()
{
	modulate = COLOR;
}

void fragment()
{
	vec4 color = texture(TEXTURE, UV);
	COLOR = color * modulate;
}

void light()
{
	vec4 color = texture(TEXTURE, UV);
	LIGHT = vec4(color.rgb * LIGHT_COLOR.rgb * LIGHT_ENERGY, LIGHT_COLOR.a);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

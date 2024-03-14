shader_type canvas_item;

uniform float range : hint_range(0.0, 0.1, 0.005)= 0.015;
uniform float noiseQuality : hint_range(0.0, 300.0, 0.1)= 57.3;
uniform float noiseIntensity : hint_range(-0.6, 0.6, 0.0010)= 0.003;
uniform float offsetIntensity : hint_range(-0.1, 0.1, 0.001) = 0.03;
uniform float colorOffsetIntensity : hint_range(0.0, 5.0, 0.001) = 0.963;
uniform vec4 modulate : source_color = vec4(1.0);
uniform float modulate_strength : hint_range(0.0, 1.0) = 0.5;

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float verticalBar(float pos, float UVY, float offset)
{
    float edge0 = (pos - range);
    float edge1 = (pos + range);

    float x = smoothstep(edge0, pos, UVY) * offset;
    x -= smoothstep(pos, edge1, UVY) * offset;
    return x;
}
const float saturation = 0.2;
void fragment()
{
    vec2 uv = UV;
    for (float i = 0.0; i < 0.71; i += 0.1313)
    {
        float d = mod(TIME * i, 1.7);
        float o = sin(1.0 - tan(TIME * 0.24 * i));
        o *= offsetIntensity;
        uv.x += verticalBar(d, UV.y, o);
    }
    
    float UVY = uv.y;
    UVY *= noiseQuality;
    UVY = float(int(UVY)) * (1.0 / noiseQuality);
    float noise = rand(vec2(TIME * 0.00001, UVY));
    uv.x += noise * noiseIntensity;

    vec2 offsetR = vec2(0.009 * sin(TIME), 0.0) * colorOffsetIntensity;
    vec2 offsetG = vec2(0.0073 * (cos(TIME * 0.97)), 0.0) * colorOffsetIntensity;
    
    float r = texture(TEXTURE, uv + offsetR).r;
    float g = texture(TEXTURE, uv + offsetG).g;
    float b = texture(TEXTURE, uv).b;
    vec3 tex = vec3(r, g, b);
    COLOR.rgb = mix(tex, modulate.rgb, modulate_strength);
}
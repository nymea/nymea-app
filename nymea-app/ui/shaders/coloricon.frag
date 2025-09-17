#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 inColor;
    vec4 outColor;
    float threshold;
};

void main() {
    vec4 sourceColor = texture(source, qt_TexCoord0);
    fragColor = mix(vec4(outColor.rgb, 1.0) * sourceColor.a, sourceColor, step(threshold, distance(sourceColor.rgb / sourceColor.a, inColor.rgb))) * qt_Opacity;
}

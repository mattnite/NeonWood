#version 460

layout(location = 0) in vec3 texPosition;
layout(location = 1) in vec3 texNormal;
layout(location = 2) in vec4 texColor;
layout(location = 3) in vec2 texCoord;

layout (location = 0) out vec4 fragColor;
layout (location = 1) out vec2 texCoords;
layout (location = 2) out int instanceId;
layout (location = 3) out vec2 pixelPosition;

struct FontInfo {
  vec2 position; // 8 bytes alignment 0
  vec2 size;     // 8 bytes alignment 8
  uint isSdf; // 4 bytes 16
  uint pad0;     // 4 bytes
  vec2 pad2;     // 8 bytes
};

layout(std140, set = 0, binding = 0) readonly buffer FontInfoBuffer{ 
    FontInfo fontInfo[];
} fontBuffer;

layout (push_constant) uniform constants {
	vec2 extent;
} PushConstants;

void main()
{
    vec2 pos = fontBuffer.fontInfo[gl_BaseInstance].position;
    vec2 size = fontBuffer.fontInfo[gl_BaseInstance].size;

    vec2 t = texPosition.xy + pos;
    pixelPosition = t;
    //gl_Position = vec4(( (texPosition.xy + pos) / PushConstants.extent) * 2 + vec2(-1.0f, -1.0f), texPosition.z, 1.0);
    gl_Position = vec4((t / PushConstants.extent) * 2 + vec2(-1.0f, -1.0f), texPosition.z, 1.0);

    texCoords = texCoord;
    fragColor = texColor;
    instanceId = gl_BaseInstance;
}

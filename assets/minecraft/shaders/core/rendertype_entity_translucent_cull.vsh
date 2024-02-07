#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
out vec4 normal;

out vec3 position;
out vec3 viewPosition;

out float isRtCube;
out vec3 rtPosition;
out vec4 pos1;
out vec4 pos2;
out vec4 pos3;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    isRtCube = 0.0;
    ivec2 atlasPixelPos = ivec2(UV0 * textureSize(Sampler0, 0));
    if(ivec4(texelFetch(Sampler0, atlasPixelPos + ivec2(0, 4), 0) * 255.0) == ivec4(105, 66, 0, 254)) {
        isRtCube = 1.0;
        rtPosition = texelFetch(Sampler0, atlasPixelPos, 0).xyz * 2.0 - 1.0;

        pos1 = pos2 = pos3 = vec4(0.0);
        switch (gl_VertexID % 4) {
            case 0: pos1 = vec4(IViewRotMat * Position, 1.0); break;
            case 1: pos2 = vec4(IViewRotMat * Position, 1.0); break;
            case 2: pos3 = vec4(IViewRotMat * Position, 1.0); break;
        }
    }

    position = IViewRotMat * Position;
    viewPosition = Position;

    vertexDistance = fog_distance(ModelViewMat, viewPosition, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}

#version 150

#moj_import <fog.glsl>
#moj_import <raytracing.glsl>

uniform sampler2D Sampler0;

uniform mat4 ProjMat;
uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec4 normal;
in vec3 position;
in vec3 viewPosition;

in float isRtCube;
in vec3 rtPosition;
in vec4 pos1;
in vec4 pos2;
in vec4 pos3;

out vec4 fragColor;

void renderRtScene() {
    vec3 p1 = pos1.xyz / pos1.w;
    vec3 p2 = pos2.xyz / pos2.w;
    vec3 p3 = pos3.xyz / pos3.w;
    vec3 faceMin = min(p1,min(p2,p3));
    vec3 faceMax = max(p1,max(p2,p3));
    vec3 faceSize = faceMax - faceMin;
    float rtScale = length(faceSize) * 0.35355339059; // sqrt(0.5)/2

    Ray ray = constructRay(position, rtPosition, rtScale);
    HitInfo hit = sphereIntersection(ray, 1.0);
    
    if(hit.hit) {
        gl_FragDepth = calcFragDepth(ray, hit.dist, ProjMat, viewPosition, rtScale);
        fragColor = vec4(vec3(pow(max(dot(hit.normal, normalize(vec3(1.0, 1.0, 1.0))), 0.0) * 0.6 + mix(0.01, 0.4, hit.normal.y * 0.5 + 0.5), 1.0/2.2)), 1.0);
    }else{
        discard;
    }
}

void main() {
    gl_FragDepth = gl_FragCoord.z;

    if(isRtCube > 0.5) {
        renderRtScene();
        return;
    }


    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}

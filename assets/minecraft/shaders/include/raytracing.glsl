struct Ray {
    vec3 origin;
    vec3 direction;
    vec3 offsetVS;
};

struct HitInfo {
    bool hit;
    float dist;
    vec3 position;
    vec3 normal;
};

Ray constructRay(vec3 position, vec3 rtPosition, float rtScale) {
    Ray ray;
    ray.offsetVS = vec3(0.0);
    ray.origin = rtPosition - (position / rtScale);
    ray.direction = normalize(position);
    return ray;
}

float calcFragDepth(Ray ray, float hitDist, mat4 projMat, vec3 viewPosition, float rtScale) {
    vec3 viewPos = ray.offsetVS + normalize(viewPosition) * rtScale * hitDist;
    vec4 clipPos = projMat * vec4(viewPos, 1.0);
    return (clipPos.z / clipPos.w + 1.0) * 0.5;
}

HitInfo sphereIntersection(Ray ray, float radius) {
    HitInfo hit;
    hit.hit = false;
    hit.dist = 0.0;
    hit.normal = vec3(0.0);

    float distToNearestPos = -dot(ray.origin, ray.direction);
    vec3 nearestPos = ray.origin + ray.direction * distToNearestPos;
    float offsetToEdgeSq = radius * radius - dot(nearestPos, nearestPos);

    if(offsetToEdgeSq < 0.0) return hit; // miss

    // hit
    float offsetToEdge = sqrt(offsetToEdgeSq);
    hit.hit = true;
    hit.dist = distToNearestPos - offsetToEdge;
    if(hit.dist < 0.0) {
        hit.dist = distToNearestPos + offsetToEdge;
        hit.hit = hit.dist >= 0.0;
        hit.position = ray.origin + ray.direction * hit.dist;
        hit.normal = normalize(hit.position);
    }else{
        hit.position = ray.origin + ray.direction * hit.dist;
        hit.normal = normalize(hit.position);
    }
    return hit;
}
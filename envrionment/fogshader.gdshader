shader_type fog;

uniform float density = 0.005;
uniform float max_height = 25.0;
uniform float start_dist = 15.0;
uniform float end_dist = 45.0;

void fog() {
	float xdist = (WORLD_POSITION.x-OBJECT_POSITION.x)*(WORLD_POSITION.x-OBJECT_POSITION.x);
	float ydist = (WORLD_POSITION.y-OBJECT_POSITION.y)*(WORLD_POSITION.y-OBJECT_POSITION.y);
	float zdist = (WORLD_POSITION.z-OBJECT_POSITION.z)*(WORLD_POSITION.z-OBJECT_POSITION.z);
	float dist = sqrt(xdist+ydist+zdist);
	
	float prop = max((dist-start_dist)/(end_dist-start_dist), 0);
	float yprop = max(1.0-(WORLD_POSITION.y/max_height), 0);
	DENSITY = prop*yprop*density;
	ALBEDO = vec3(1.0);
}

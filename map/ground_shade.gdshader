shader_type spatial;


uniform vec3 grass_color: source_color = vec3(0.41, 0.754, 0.37);
uniform vec3 dark_grass_color: source_color = vec3(0.212, 0.411, 0.189);
uniform vec3 dirt_color: source_color = vec3(0.504, 0.334, 0.102);
uniform vec3 dark_dirt_color: source_color = vec3(0.373, 0.243, 0.065);
uniform sampler2D noise_tex;
uniform float noise_scale = 3.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 worldNormal = (INV_VIEW_MATRIX * vec4(NORMAL.xyz, 0.0)).xyz;
	float uppies = worldNormal.y;
	
	vec3 col;
	vec3 dark_col;
	
	if (uppies > 0.1) {
		col = grass_color;
		dark_col = dark_grass_color;
	} else {
		col = dirt_color;
		dark_col = dark_dirt_color;
	}
	
	//ALBEDO = vec3(UV, 0.0);
	vec4 textur = texture(noise_tex, UV*noise_scale);
	float value = textur.r;
	value += sqrt(value);
	ALBEDO = (col*value)+(dark_col*(1.0-value));
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

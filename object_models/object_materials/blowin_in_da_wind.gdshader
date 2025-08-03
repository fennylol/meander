// This is actually a spatial shader - correcting the shader_type
shader_type spatial;

// Wind parameters
uniform float wind_strength : hint_range(0.0, 2.0) = 0.5;
uniform float wind_speed : hint_range(0.0, 5.0) = 1.0;
uniform vec2 wind_direction = vec2(1.0, 0.0);

// Noise texture for wind variation
uniform sampler2D noise_texture;
uniform float noise_scale : hint_range(0.1, 10.0) = 1.0;
uniform float noise_strength : hint_range(0.0, 1.0) = 0.3;

// Tree-specific parameters
uniform float trunk_stiffness : hint_range(0.0, 1.0) = 0.8;
uniform float height_influence : hint_range(0.0, 3.0) = 1.5;

varying vec3 world_position;

void vertex() {
	// Get the world position FIRST
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// Calculate height factor (higher vertices move more)
	// Use world Y coordinate for consistent height across all trees
	float world_height = world_position.y;
	float height_factor = clamp(world_height * height_influence * 0.1, 0.0, 1.0);

	// Reduce movement near the trunk (lower world Y values)
	float trunk_factor = 1.0 - (trunk_stiffness * (1.0 - height_factor));

	// Use world coordinates for noise sampling - this creates coherent wind patterns
	// The noise texture acts like a wind map moving across the world
	vec2 wind_map_uv = world_position.xz * noise_scale * 0.01 + wind_direction * TIME * wind_speed * 0.1;
	float noise_sample = texture(noise_texture, wind_map_uv).r;

	// Create wind gusts that travel across the world based on world coordinates
	vec2 world_wind_phase = world_position.xz * 0.1 + wind_direction * TIME * wind_speed;
	vec2 base_wind = wind_direction * wind_strength * sin(world_wind_phase.x + world_wind_phase.y);

	// Modulate base wind with noise for realistic variation
	float wind_intensity = noise_sample * noise_strength + (1.0 - noise_strength);
	vec2 wind_offset = base_wind * wind_intensity;

	// Apply height and trunk factors
	wind_offset *= height_factor * trunk_factor;

	// Displace vertex in XZ plane (in local space)
	VERTEX.x += wind_offset.x;
	VERTEX.z += wind_offset.y;

	// Optional: Add slight Y movement synchronized across world
	float world_wave = sin(TIME * wind_speed * 1.5 + world_position.x * 0.3 + world_position.z * 0.3);
	VERTEX.y += world_wave * wind_strength * 0.05 * height_factor * noise_sample;
}


void fragment() {
	ALBEDO = vec3(0.429, 1.0, 0.456);
	METALLIC = 0.0;
	SPECULAR = 0.0;
	ROUGHNESS = 1.0;
	AO_LIGHT_AFFECT = 0.5;
}

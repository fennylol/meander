extends FogVolume

func update_shader_params(density: float, start_dist: float = 15, end_dist: float = 45):
	material.set_shader_parameter("density", density)
	material.set_shader_parameter("start_dist", start_dist)
	material.set_shader_parameter("end_dist", end_dist)

extends ColorRect

@export var light_path : NodePath
@onready var light : DirectionalLight3D = get_node(light_path)   

@export var camera_path : NodePath
@onready var camera : Camera3D = get_node(camera_path)

var norm_ray_length = 1.0
var norm_ray_intensity = 1.0
var norm_light_source_scale = 3
var norm_light_source_feather = 0.5

var faded_ray_length = 1.0
var faded_ray_intensity = 1.0
var faded_light_source_scale = 1.0
var faded_light_source_feather = 2.0

func update_shader_params(prop: float) -> void:
	var pos = camera.unproject_position(camera.global_position - (-light.global_basis.z.normalized()))   
	material.set_shader_parameter("light_source_pos", pos)
	material.set_shader_parameter("light_source_dir", -light.global_basis.z)
	material.set_shader_parameter("camera_dir", -camera.global_basis.z)
	material.set_shader_parameter("lc", light.light_color)
	
	material.set_shader_parameter("ray_length", lerpf(norm_ray_length, norm_ray_length, prop))
	material.set_shader_parameter("ray_intensity", lerpf(norm_ray_intensity, norm_ray_intensity, prop))
	material.set_shader_parameter("light_source_scale", lerpf(norm_light_source_scale, norm_light_source_scale, prop))
	material.set_shader_parameter("light_source_feather", lerpf(norm_light_source_feather, norm_light_source_feather, prop))

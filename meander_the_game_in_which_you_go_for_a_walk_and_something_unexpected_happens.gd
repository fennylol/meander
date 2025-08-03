extends Node3D


@onready var cloud_noise: FastNoiseLite = $WorldEnvironment.environment.sky.sky_material.panorama.noise
@onready var sky_gradient: Gradient = $WorldEnvironment.environment.sky.sky_material.panorama.color_ramp
@onready var ambiant_light =  $WorldEnvironment.environment.ambient_light_energy
@onready var sun: DirectionalLight3D = $DirectionalLight3D
@onready var light_ray_shader = $Control/ColorRect
@onready var fog_shader = $CharacterBody3D/FogVolume
@onready var sounds = $global_sounds


static func get_progress_from_time(time : Array) -> float:
	return  float(time[HOUR])  /float(HOURS_PER_DAY) + \
			float(time[MINUTE])/float(HOURS_PER_DAY * MINUTES_PER_HOUR) + \
			float(time[SECOND])/float(HOURS_PER_DAY * MINUTES_PER_HOUR * SECONDS_PER_MINUTE)

var day_progress: float = 0.0
var time_paused: bool = false

var cloud_speed: float = 1.5


enum {HOUR, MINUTE, SECOND, DAY}
const SECONDS_PER_MINUTE: float = 60.0
const MINUTES_PER_HOUR: int = 60
const HOURS_PER_DAY: int = 24
var IN_GAME_MINUTE_LENGTH_IN_REAL_WORLD_SECONDS: float = .625

var world_time: Array = [-1, 35, 60.0, -1]
var SUNRISE_TIME: Array = [0, 35, 0]
var SUNSET_TIME: Array = [11, 30, 0]

var DAYTIME_SKY_COLOR: Color = Color(0.337, 0.507, 0.663)
var NIGHTTIME_SKY_COLOR: Color = Color(0.103, 0.184, 0.258)
var SUNRISE_COLOR: Color = Color(0.904, 0.482, 0.391)
var SUNSET_COLOR: Color = Color(0.691, 0.402, 0.022)
var DEFAULT_SUN_COLOR: Color = Color(0.724, 0.721, 0.552)

var MAX_TIME_BASED_FOG_DENSITY: float = 0.05
var MIN_TIME_BASED_FOG_DENSITY: float = 0.01

func _ready() -> void: 
	cloud_noise.seed = randi()
	var resize_subviewport = func(): $SubViewportContainer/SubViewport.size = get_viewport().size
	resize_subviewport.call()
	get_viewport().size_changed.connect(resize_subviewport)

func _process(delta):
	# advance time and calculate day_progress
	if not time_paused:
		world_time[SECOND] += delta*(SECONDS_PER_MINUTE/IN_GAME_MINUTE_LENGTH_IN_REAL_WORLD_SECONDS)
		
		if world_time[SECOND] >= SECONDS_PER_MINUTE :
			world_time[SECOND] -= SECONDS_PER_MINUTE
			world_time[MINUTE] = (world_time[MINUTE] + 1) % MINUTES_PER_HOUR
			if world_time[MINUTE] == 0: world_time[HOUR] = ((world_time[HOUR] + 1) % HOURS_PER_DAY)
			if  world_time[MINUTE] == 0 and  world_time[HOUR] == 0: world_time[DAY] += 1
	day_progress = get_progress_from_time(world_time)
	
	# adjust light color according to day_progress	
	var progress_from_sunrise: float = get_progress_from_time(SUNRISE_TIME) - day_progress
	var progress_from_sunset: float = get_progress_from_time(SUNSET_TIME) - day_progress
	var diff = 0
	
	var max_diff = get_progress_from_time([1,30,0])
	var light_color: Color = DEFAULT_SUN_COLOR
	var sky_color: Color = DAYTIME_SKY_COLOR if progress_from_sunset > 0 else NIGHTTIME_SKY_COLOR
	
	if absf(progress_from_sunrise) < max_diff:
		diff = (max_diff-absf(progress_from_sunrise))/max_diff
		light_color = Color(SUNRISE_COLOR*diff + DEFAULT_SUN_COLOR*(1-diff))
		sounds.time_till_sunrise(progress_from_sunrise, diff)
		if progress_from_sunrise > 0:
			sky_color = Color(DAYTIME_SKY_COLOR*diff + NIGHTTIME_SKY_COLOR*(1-diff))
			ambiant_light = (0.04*diff + 0.03*(1-diff))
	elif absf(progress_from_sunset) < max_diff:
		diff = (max_diff-absf(progress_from_sunset))/max_diff
		light_color = Color(SUNSET_COLOR*diff + DEFAULT_SUN_COLOR*(1-diff))
		sounds.time_till_sunset(progress_from_sunset, diff)
		if progress_from_sunset < 0:
			sky_color = Color(NIGHTTIME_SKY_COLOR*diff + DAYTIME_SKY_COLOR*(1-diff))
			ambiant_light = (0.03*diff + 0.04*(1-diff))
	
	sky_gradient.colors[0] = sky_color
	sun.light_color = light_color
	
	
	light_ray_shader.update_shader_params(diff)
	var fog_density = ((MAX_TIME_BASED_FOG_DENSITY-MIN_TIME_BASED_FOG_DENSITY)*diff)+MIN_TIME_BASED_FOG_DENSITY
	fog_shader.update_shader_params(fog_density)
	
	# rotate sun and clouds
	sun.rotation_degrees.x = -day_progress*360
	cloud_noise.offset.x += delta*cloud_speed
	
	var fps = Engine.get_frames_per_second()
	$gui/Label.text = "FPS: " + str(fps)
	
	#print(world_time, '\n', day_progress)

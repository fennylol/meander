extends Node3D


@onready var cloud_noise: FastNoiseLite = $WorldEnvironment.environment.sky.sky_material.panorama.noise
@onready var sun: DirectionalLight3D = $DirectionalLight3D
@onready var shader = $Control/ColorRect


var day_progress: float = 0.0
var time_paused: bool = false
var day_length: float = 60.0

var cloud_speed: float = 3.0




enum {HOUR, MINUTE, SECOND, DAY}
const SECONDS_PER_MINUTE: float = 60.0
const MINUTES_PER_HOUR: int = 60
const HOURS_PER_DAY: int = 24
var IN_GAME_MINUTE_LENGTH_IN_REAL_WORLD_SECONDS: float = .1

var SUNRISE_TIME: Array = [0, 0, 0]
var SUNRISE_COLOR: Color = Color.DEEP_PINK
var SUNSET_TIME: Array = [12, 0, 0]
var SUNSET_COLOR: Color = Color.DARK_ORANGE
var DEFAULT_SUN_COLOR: Color = Color.WHITE
var world_time: Array = [23, 59, 60.0, -1]





func _ready() -> void: 
	cloud_noise.seed = randi()
	
	var resize_subviewport = func(): $SubViewportContainer/SubViewport.size = get_viewport().size
	resize_subviewport.call()
	get_viewport().size_changed.connect(resize_subviewport)

func _process(delta):
	if not time_paused:
		world_time[SECOND] += delta*(SECONDS_PER_MINUTE/IN_GAME_MINUTE_LENGTH_IN_REAL_WORLD_SECONDS)
		
		if world_time[SECOND] >= SECONDS_PER_MINUTE :
			world_time[SECOND] -= SECONDS_PER_MINUTE
			world_time[MINUTE] = (world_time[MINUTE] + 1) % MINUTES_PER_HOUR
			if world_time[MINUTE] == 0: world_time[HOUR] = ((world_time[HOUR] + 1) % HOURS_PER_DAY)
			if  world_time[MINUTE] == 0 and  world_time[HOUR] == 0: world_time[DAY] += 1
		
	day_progress = get_progress_from_time(world_time)
	
	var max_diff = get_progress_from_time([1,30,0])
	var color = DEFAULT_SUN_COLOR
	
	var progress_from_sunrise: float = absf(get_progress_from_time(SUNRISE_TIME) - day_progress)
	var progress_from_sunset: float = absf(get_progress_from_time(SUNSET_TIME) - day_progress)
	var diff = 0
	
	if progress_from_sunrise < max_diff:
		diff = (max_diff-progress_from_sunrise)/max_diff
		color = Color(SUNRISE_COLOR*diff + DEFAULT_SUN_COLOR*(1-diff))
	elif progress_from_sunset < max_diff:
		diff = (max_diff-progress_from_sunset)/max_diff
		color = Color(SUNSET_COLOR*diff + DEFAULT_SUN_COLOR*(1-diff))
	sun.light_color = color
	
	shader.update_shader_params(diff)
	
	
	sun.rotation_degrees.x = -day_progress*360
	cloud_noise.offset.x += delta*cloud_speed
	
	var fps = Engine.get_frames_per_second()
	$gui/Label.text = "FPS: " + str(fps)
	
	#print(world_time, '\n', day_progress)


func get_progress_from_time(time : Array) -> float:
	return  float(time[HOUR])  /float(HOURS_PER_DAY) + \
			float(time[MINUTE])/float(HOURS_PER_DAY * MINUTES_PER_HOUR) + \
			float(time[SECOND])/float(HOURS_PER_DAY * MINUTES_PER_HOUR * SECONDS_PER_MINUTE)

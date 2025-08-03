extends Node


@onready var birds_player: AudioStreamPlayer = $birds
@onready var cicadas_player: AudioStreamPlayer = $cicadas

var max_volume = -10
var min_volume = -80

func _ready() -> void:
	birds_player.playing = true
	cicadas_player.playing = true

func time_till_sunrise(prog: float, diff: float):
	if prog > 0:
		var volume : float = (max_volume*diff)+((1-diff)*min_volume)
		birds_player.volume_db = volume
		
		diff = max(diff-0.5, 0.0)
		volume = (min_volume*diff)+((1-diff)*max_volume)
		cicadas_player.volume_db = volume


func time_till_sunset(prog: float, diff: float):
	if prog > 0:
		var volume : float = (max_volume*diff)+((1-diff)*min_volume)
		cicadas_player.volume_db = volume
		
		diff = max(diff-0.5, 0.0)
		volume = (min_volume*diff)+((1-diff)*max_volume)
		birds_player.volume_db = volume

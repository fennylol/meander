extends Area3D

@export var IsFinal: bool = false
signal finished

func _on_body_entered(body: Node3D) -> void:
	if (body.is_in_group("player")):
		if !IsFinal:
			body.score += 1
			self.queue_free()
		elif (IsFinal and body.score >= body.MAX_SCORE):
			body.score += 1
			self.queue_free()
			finished.emit()
			

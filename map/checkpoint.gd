extends Area3D

@export var IsFinal: bool = false

func _on_body_entered(body: Node3D) -> void:
	if (body.is_in_group("player")):
		if (IsFinal and body.score == body.MAX_SCORE) or !IsFinal:
			body.score += 1
			self.queue_free()

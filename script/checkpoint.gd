extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.set_checkpoint(global_position)
		print("Checkpoint berhasil diambil!")

extends Area2D

@onready var timer: Timer = $Timer
@onready var jatuh: AudioStreamPlayer = $jatuh

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":  # Pastikan yang masuk adalah Player
		jatuh.play()  # Mainkan suara jatuh
		timer.start()  # Mulai timer untuk respawn

func _on_timer_timeout() -> void:
	var player = get_tree().current_scene.find_child("Player", true, false)
	if player:
		player.respawn()  # Respawn ke checkpoint
	else:
		print("ERROR: Player tidak ditemukan!")

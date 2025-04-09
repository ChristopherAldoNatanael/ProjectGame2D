extends Control

@onready var click_sound: AudioStreamPlayer = $ClickSound

func _on_start_pressed() -> void:
	click_sound.play()
	await get_tree().create_timer(0.3).timeout  # Tunggu sedikit agar suara terdengar
	get_tree().change_scene_to_file("res://scene/cuyrun.tscn")

func _on_settings_pressed() -> void:
	click_sound.play()
	print("Settings pressed")

func _on_exit_pressed() -> void:
	click_sound.play()
	await get_tree().create_timer(0.3).timeout  # Tunggu sebentar
	get_tree().quit()

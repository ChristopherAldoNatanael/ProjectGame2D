extends Control

@onready var home_button: TextureButton = $ButtonContainer/HomeButton
@onready var restart_button: TextureButton = $ButtonContainer/RestartButton
@onready var resume_button: TextureButton = $ButtonContainer/ResumeButton

func _ready() -> void:
	hide()
	
	# Hubungkan sinyal
	home_button.pressed.connect(_on_home_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	resume_button.pressed.connect(_on_resume_button_pressed)

# Tampilkan menu pause dengan animasi
func show_menu(global_position: Vector2) -> void:
	visible = true
	position = global_position
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

# Tombol resume
func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()

# Tombol restart
func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

# Tombol home
func _on_home_button_pressed() -> void:
	print("Home button diklik!")
	get_tree().paused = false
	await get_tree().process_frame
	var error = get_tree().change_scene_to_file("res://scene/main_menu.tscn")
	if error != OK:
		print("❌ Gagal pindah scene:", error)
	else:
		print("✅ Berhasil pindah ke MainMenu")

extends Area2D

@export var dialog_texts: Array[String] = []  # Teks dari Inspector
var dialog_system: Node
var player_inside = false

func _ready():
	dialog_system = get_tree().current_scene.find_child("DialogSystem", true, false)
	if dialog_system == null:
		print("🚨 ERROR: DialogSystem tidak ditemukan di scene: ", get_tree().current_scene.name)
	else:
		print("✅ DialogSystem ditemukan: ", dialog_system.name)

func _on_body_entered(body):
	if body.name == "Player" and dialog_system and not player_inside:
		if dialog_texts.is_empty():
			print("⚠️ Tidak ada teks dialog yang diatur di Inspector!")
			return
		player_inside = true
		start_dialog_loop()

func start_dialog_loop():
	if dialog_system:
		dialog_system.show_dialog(dialog_texts, self)
		await dialog_system.dialog_finished  # Menunggu signal dari DialogSystem
		player_inside = false

func _on_body_exited(body):
	if body.name == "Player":
		player_inside = false
		print("❌ Player keluar dari block, menghentikan dialog...")
		if dialog_system:
			dialog_system.request_close_dialog(self)

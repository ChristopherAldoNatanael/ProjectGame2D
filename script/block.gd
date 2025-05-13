extends Area2D

@export var dialog_texts: Array[String] = ["Apa kekhawatiran utama masyarakat sipil terhadap revisi UU TNI 2025?"]
@onready var dialog_label: Label = $CanvasLayer/DialogLabel
@onready var dialog_background: ColorRect = $CanvasLayer/DialogBackground
@onready var camera: Camera2D = get_tree().get_first_node_in_group("player_camera")
@onready var audio_player: AudioStreamPlayer = get_node("CanvasLayer/BGMusic")  # Pastikan ini benar

var current_index = 0
var is_displaying = false
var is_typing = false
var player_inside = false

func _ready():
	if not is_connected("body_entered", _on_body_entered):
		connect("body_entered", _on_body_entered)
	if not is_connected("body_exited", _on_body_exited):
		connect("body_exited", _on_body_exited)

	dialog_background.visible = false
	dialog_label.visible = false

	if audio_player:
		audio_player.process_mode = Node.PROCESS_MODE_ALWAYS  

func _on_body_entered(body):
	if body.name == "Player" and not is_displaying:
		player_inside = true
		print("✅ Player menyentuh block, menampilkan teks...")
		pause_player()
		show_dialog()

func _on_body_exited(body):
	if body.name == "Player":
		player_inside = false
		print("❌ Player keluar dari block, menutup dialog...")
		close_dialog()

func pause_player():
	get_tree().paused = true
	if audio_player:
		audio_player.process_mode = Node.PROCESS_MODE_ALWAYS

func resume_player():
	get_tree().paused = false
	if audio_player and audio_player.playing:
		audio_player.stop()

func show_dialog():
	if dialog_texts.is_empty():
		return
	
	is_displaying = true
	dialog_background.visible = true
	dialog_label.visible = true
	current_index = 0

	next_dialog()
	set_process(true)

func _process(delta):
	if is_displaying and camera:
		update_dialog_position()

func update_dialog_position():
	if camera:
		var screen_center = camera.get_screen_center_position()
		var offset = Vector2(0, -100)
		dialog_background.global_position = screen_center + offset - dialog_background.size / 2
		dialog_label.global_position = dialog_background.global_position + Vector2(20, 10)

func next_dialog():
	if is_typing or not player_inside:
		return

	if current_index < dialog_texts.size():
		dialog_label.text = ""
		# Proses teks untuk mengganti <br> dengan \n
		var processed_text = dialog_texts[current_index].replace("<br>", "\n")
		type_text(processed_text)
		current_index += 1
	else:
		close_dialog()

func type_text(full_text: String):
	is_typing = true
	for i in range(full_text.length()):
		if not player_inside:
			break
		dialog_label.text += full_text[i]
		update_background_size()
		await get_tree().create_timer(0.1).timeout
	
	is_typing = false
	if player_inside:
		await get_tree().create_timer(1.5).timeout
		if player_inside:
			next_dialog()

func update_background_size():
	await get_tree().process_frame
	var text_size = dialog_label.get_minimum_size()
	var padding = Vector2(40, 20)
	dialog_background.size = text_size + padding
	dialog_background.global_position = dialog_label.global_position - Vector2(20, 10)

func close_dialog():
	dialog_background.visible = false
	dialog_label.visible = false
	is_displaying = false
	is_typing = false
	set_process(false)
	resume_player()

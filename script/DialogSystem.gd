extends CanvasLayer

signal dialog_finished  # Deklarasi signal baru

@onready var dialog_label: Label = $DialogLabel
@onready var dialog_background: ColorRect = $DialogBackground

var dialog_list = []
var current_index = 0
var is_displaying = false
var is_typing = false
var dialogue_owner = null
var typing_speed = 0.08
var skip_typing = false  # Flag untuk skip ketikan

func _ready():
	dialog_background.visible = false
	dialog_label.visible = false

	# Gunakan font dari user
	var font = load("res://assets/font pixel/GrapeSoda.ttf")
	dialog_label.add_theme_font_override("font", font)
	dialog_label.add_theme_font_size_override("font_size", 48)
	dialog_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))

func show_dialog(dialogs: Array, owner = null):
	if is_displaying:
		return  # Abaikan jika dialog masih berjalan

	is_displaying = true
	dialog_list = dialogs.duplicate()  # Hindari perubahan langsung pada array asli
	current_index = 0
	dialogue_owner = owner

	dialog_background.visible = true
	dialog_label.visible = true
	dialog_label.text = ""

	next_dialog()

func next_dialog():
	if is_typing:
		skip_typing = true  # Set flag untuk langsung menampilkan teks penuh
		return

	if current_index < dialog_list.size():
		dialog_label.text = ""
		type_text(dialog_list[current_index])
		current_index += 1
	else:
		close_dialog()

func type_text(full_text: String):
	is_typing = true
	skip_typing = false  # Reset flag skip
	dialog_label.text = ""

	# Pastikan "\n" terbaca sebagai newline di Label
	full_text = full_text.replace("\\n", "\n")

	for i in range(full_text.length()):
		if skip_typing:  
			dialog_label.text = full_text  # Langsung tampilkan teks penuh
			break

		# Periksa apakah karakter saat ini adalah newline
		if full_text[i] == "\n":
			dialog_label.text += "\n"
		else:
			dialog_label.text += full_text[i]

		await get_tree().create_timer(typing_speed).timeout
	
	is_typing = false
	await get_tree().create_timer(0.5).timeout  # Jeda sebelum lanjut

func close_dialog():
	is_displaying = false
	is_typing = false
	skip_typing = false
	dialog_background.visible = false
	dialog_label.visible = false
	dialogue_owner = null
	emit_signal("dialog_finished")  # Emit signal saat dialog selesai

func _input(event):
	if event.is_action_pressed("ui_accept") and is_displaying:
		next_dialog()

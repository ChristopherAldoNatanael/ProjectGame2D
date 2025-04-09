# LevelTrigger.gd
extends Node2D

class_name LevelTrigger

# Exported variables untuk Inspector
@export_enum("Level 1", "Level 2", "Level 3") var level_text: String = "Level 1"
@export var custom_font: FontFile
@export var text_color: Color = Color.WHITE
@export var trigger_area: Area2D

# Label untuk menampilkan teks
@onready var level_label: Label = $LevelLabel
# AudioStreamPlayer langsung dari scene tree
@onready var audio_player_node: AudioStreamPlayer2D = $AudioPlayer

# Variabel internal
var is_player_inside: bool = false
const BASE_FONT_SIZE: int = 64
const ANIMATION_DURATION: float = 1.0

func _ready() -> void:
	# Validasi awal
	if not trigger_area:
		printerr("Trigger Area tidak diset di Inspector!")
		return
	if not level_label:
		printerr("LevelLabel tidak ditemukan!")
		return
	if not audio_player_node:
		printerr("Node 'AudioPlayer' tidak ditemukan di scene! Pastikan ada node bernama 'AudioPlayer' tipe AudioStreamPlayer.")
		return
	
	_setup_label()
	_setup_connections()
	_setup_audio()
	
	# Sembunyikan label saat start dan set ke transparan
	level_label.hide()
	level_label.modulate.a = 0.0
	level_label.scale = Vector2(0.5, 0.5)

func _setup_label() -> void:
	# Konfigurasi label
	level_label.text = level_text
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	if custom_font:
		level_label.add_theme_font_override("font", custom_font)
	
	level_label.add_theme_font_size_override("font_size", BASE_FONT_SIZE)
	level_label.add_theme_color_override("font_color", text_color)
	
	# Posisi tengah
	level_label.position = Vector2(-100, -50)
	level_label.size = Vector2(200, 100)

func _setup_connections() -> void:
	trigger_area.body_entered.connect(_on_body_entered)
	trigger_area.body_exited.connect(_on_body_exited)

func _setup_audio() -> void:
	if audio_player_node:
		# Coba gunakan stream yang sudah ada
		if audio_player_node.stream:
			audio_player_node.volume_db = 0.0
			audio_player_node.autoplay = false
			print("AudioPlayer ditemukan dan dikonfigurasi dengan stream: ", audio_player_node.stream.resource_path)
		else:
			# Muat file audio secara manual
			var audio_file_path = "res://assets/audio/level.ogg"  # Path ke file audio Anda
			var audio_stream = load(audio_file_path) as AudioStream
			if audio_stream:
				audio_player_node.stream = audio_stream
				audio_player_node.volume_db = 0.0
				audio_player_node.autoplay = false
				print("Audio berhasil dimuat secara manual dari: ", audio_file_path)
			else:
				printerr("Gagal memuat audio dari path: ", audio_file_path, ". Pastikan file ada dan format didukung (WAV, MP3, OGG).")
	else:
		printerr("AudioPlayer tidak ditemukan di scene!")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") and not is_player_inside:
		is_player_inside = true
		show_level()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		is_player_inside = false
		hide_level()

func show_level() -> void:
	# Tampilkan label
	level_label.show()
	
	# Buat Tween untuk animasi
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Animasi fade in
	tween.tween_property(level_label, "modulate:a", 1.0, ANIMATION_DURATION * 0.3)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	
	# Animasi scale dengan efek bounce
	tween.tween_property(level_label, "scale", Vector2(1.2, 1.2), ANIMATION_DURATION * 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(level_label, "scale", Vector2(1.0, 1.0), ANIMATION_DURATION * 0.2)\
		.from(Vector2(1.2, 1.2))\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)\
		.set_delay(ANIMATION_DURATION * 0.3)
	
	# Mainkan musik
	if audio_player_node and audio_player_node.stream:
		audio_player_node.play()
		print("Memutar audio: ", audio_player_node.stream.resource_path)
	else:
		printerr("Tidak bisa memutar audio: stream tidak ditemukan di AudioPlayer!")

func hide_level() -> void:
	# Buat Tween untuk animasi keluar
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Animasi fade out
	tween.tween_property(level_label, "modulate:a", 0.0, ANIMATION_DURATION * 0.3)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)
	
	# Animasi scale keluar
	tween.tween_property(level_label, "scale", Vector2(0.5, 0.5), ANIMATION_DURATION * 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
	
	# Sembunyikan setelah selesai
	tween.tween_callback(level_label.hide)
	
	# Stop audio jika masih bermain
	if audio_player_node and audio_player_node.playing:
		audio_player_node.stop()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if Engine.is_editor_hint() and trigger_area:
		draw_rect(Rect2(trigger_area.position - Vector2(16, 16), Vector2(32, 32)), 
				Color.BLUE, false, 2.0)

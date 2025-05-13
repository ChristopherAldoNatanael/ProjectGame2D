extends Node2D

class_name LevelTrigger

@export_enum("Level 1", "Level 2", "Level 3", "Finish") var level_text: String = "Level 1"
@export var custom_font: FontFile
@export var text_color: Color = Color.WHITE
@export var trigger_area: Area2D
@export var audio_stream: AudioStream  # Tambahkan export untuk stream audio di Inspector

@onready var level_label: Label = $LevelLabel
@onready var audio_player_node: AudioStreamPlayer2D = $AudioPlayer

var is_player_inside: bool = false
const BASE_FONT_SIZE: int = 64
const ANIMATION_DURATION: float = 1.0

func _ready() -> void:
	print("🎯 LevelTrigger diinisialisasi di: ", get_path())
	if not trigger_area:
		printerr("Trigger Area tidak diset di Inspector!")
		return
	if not level_label:
		printerr("LevelLabel tidak ditemukan!")
		return
	if not audio_player_node:
		printerr("Node 'AudioPlayer' tidak ditemukan di scene!")
		return

	_setup_label()
	_setup_connections()
	_setup_audio()

	level_label.hide()
	level_label.modulate.a = 0.0
	level_label.scale = Vector2(0.5, 0.5)

func _setup_label() -> void:
	level_label.text = level_text
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	if custom_font:
		level_label.add_theme_font_override("font", custom_font)

	level_label.add_theme_font_size_override("font_size", BASE_FONT_SIZE)
	level_label.add_theme_color_override("font_color", text_color)

	level_label.position = Vector2(-100, -50)
	level_label.size = Vector2(200, 100)

func _setup_connections() -> void:
	trigger_area.body_entered.connect(_on_body_entered)
	trigger_area.body_exited.connect(_on_body_exited)

func _setup_audio() -> void:
	if audio_player_node:
		if audio_stream:
			audio_player_node.stream = audio_stream
			audio_player_node.volume_db = 0.0
			audio_player_node.autoplay = false
			print("AudioPlayer ditemukan dan dikonfigurasi dengan stream: ", audio_player_node.stream.resource_path)
		else:
			print("Tidak ada stream audio yang diset di Inspector untuk AudioPlayer.")
	else:
		printerr("AudioPlayer tidak ditemukan di scene!")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") and not is_player_inside:
		is_player_inside = true
		if level_text == "Finish":
			# Pindah ke main menu setelah animasi selesai
			show_level()
			await get_tree().create_timer(ANIMATION_DURATION).timeout
			get_tree().change_scene_to_file("res://scene/main_menu.tscn")
		else:
			show_level()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		is_player_inside = false
		hide_level()

func show_level() -> void:
	level_label.show()

	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(level_label, "modulate:a", 1.0, ANIMATION_DURATION * 0.3)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(level_label, "scale", Vector2(1.2, 1.2), ANIMATION_DURATION * 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(level_label, "scale", Vector2(1.0, 1.0), ANIMATION_DURATION * 0.2)\
		.from(Vector2(1.2, 1.2))\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)\
		.set_delay(ANIMATION_DURATION * 0.3)

	if audio_player_node and audio_player_node.stream:
		audio_player_node.play()
		print("Memutar audio: ", audio_player_node.stream.resource_path)

func hide_level() -> void:
	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(level_label, "modulate:a", 0.0, ANIMATION_DURATION * 0.3)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)

	tween.tween_property(level_label, "scale", Vector2(0.5, 0.5), ANIMATION_DURATION * 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)

	tween.tween_callback(level_label.hide)

	if audio_player_node and audio_player_node.playing:
		audio_player_node.stop()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if Engine.is_editor_hint() and trigger_area:
		draw_rect(Rect2(trigger_area.position - Vector2(16, 16), Vector2(32, 32)), 
				Color.BLUE, false, 2.0)

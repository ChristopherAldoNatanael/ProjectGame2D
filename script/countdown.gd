extends Label

@onready var timer: Timer = $Timer
@onready var timeout_label: Label = get_tree().current_scene.find_child("TimeoutLabel", true, false)
@onready var player: Node2D = get_tree().current_scene.find_child("Player", true, false)
@onready var camera: Camera2D = get_tree().current_scene.find_child("Camera2D", true, false)

var countdown: int = 30
var is_running: bool = false  # **Tambahkan flag untuk menentukan apakah timer sudah berjalan**

func updateLabelText() -> void:
	text = str(countdown)

func _ready() -> void:
	updateLabelText()
	timer.wait_time = 1
	timer.autostart = false  # **Matikan autostart agar timer tidak langsung mulai**
	
	# **Hubungkan signal dari Controller ke countdown**
	if Controller:
		Controller.connect("my_coin", add_coin)

	# **Pastikan TimeoutLabel disembunyikan setiap kali scene dimulai ulang**
	if timeout_label:
		timeout_label.visible = false
		timeout_label.text = ""

func _process(delta: float) -> void:
	# **Buat tulisan timeout mengikuti kamera (tengah layar)**
	if timeout_label and camera:
		timeout_label.global_position = camera.global_position - (timeout_label.size / 2)

# **Fungsi ini dipanggil saat koin diambil**
func add_coin(coin: int) -> void:
	countdown += 5
	updateLabelText()
	
	# **Mulai timer hanya jika belum berjalan**
	if not is_running:
		is_running = true
		timer.start()

	print("Waktu bertambah! Sekarang:", countdown)  # Debugging

func _on_timer_timeout() -> void:
	if countdown > 0:
		countdown -= 1
		updateLabelText()
	else:
		timer.stop()
		show_timeout_message()
		await get_tree().create_timer(2.0).timeout
		Controller.reset_coin()
		get_tree().reload_current_scene()

# **Fungsi untuk menampilkan pesan TIMEOUT dengan efek pixel**
func show_timeout_message() -> void:
	if timeout_label == null:
		print("ERROR: TimeoutLabel tidak ditemukan!")
		return

	timeout_label.text = "TIMEOUT"
	timeout_label.visible = true
	timeout_label.add_theme_color_override("font_color", Color.RED)
	timeout_label.add_theme_font_size_override("font_size", 48)

	# **Efek animasi pixel membesar dengan Tween**
	var tween = get_tree().create_tween()
	timeout_label.scale = Vector2(0.5, 0.5)
	tween.tween_property(timeout_label, "scale", Vector2(1.5, 1.5), 0.5).set_trans(Tween.TRANS_BOUNCE)

extends Node2D

@export var coin_id: String = ""  # ID unik untuk tiap koin (atur di Inspector)

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# Dictionary statis untuk menyimpan koin yang sudah diambil
static var collected_coins = {}

func _ready():
	# Jika ID kosong, beri ID unik otomatis
	if coin_id == "":
		coin_id = str(get_instance_id())  # ID unik berdasarkan instance

	# Jika koin sudah diambil sebelumnya, langsung hapus dari scene
	if coin_id in collected_coins:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not collected_coins.has(coin_id):  # Pastikan koin belum diambil
		collected_coins[coin_id] = true  # Tandai koin sebagai sudah diambil
		Controller.add_coin()  # Tambahkan koin ke skor

		audio_stream_player.play()  # Mainkan suara koin sebelum dihapus
		visible = false  # Sembunyikan koin dari layar
		set_process(false)
		set_physics_process(false)

		await audio_stream_player.finished  # Tunggu suara selesai sebelum dihapus
		queue_free()  # Hapus koin dari scene

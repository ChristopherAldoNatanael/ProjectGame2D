extends Label

func get_coin(coin: int) -> void:
	text = str("+", coin)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Controller.connect("my_coin", get_coin) # INI ADALAH SIGNAL
	
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":  
		Controller.add_coin()  # Tambah koin
		queue_free()  # Hapus koin setelah diambil

extends Node

var coin: int = 0

signal my_coin(coin: int)

func add_coin() -> void:
	coin += 1
	emit_signal("my_coin", coin)
	print("Koin bertambah! Total:", coin)  # Debugging

func reset_coin() -> void:
	coin = 0
	emit_signal("my_coin", coin)
	print("Koin di-reset!")  # Debugging

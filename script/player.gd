extends CharacterBody2D

const SPEED = 410.0
const JUMP_VELOCITY = -750.0

@onready var player_ui: AnimatedSprite2D = $AnimatedSprite2D
@onready var checkpoint_label: Label = get_tree().current_scene.find_child("CheckpointLabel", true, false)
@onready var camera: Camera2D = $Camera2D
@onready var jump: AudioStreamPlayer = $jump
@onready var spawn: AudioStreamPlayer = $spawn

var checkpoint_position: Vector2
var was_in_air = false
var pause_menu_scene: PackedScene = preload("res://scene/PauseMenu.tscn")
var pause_menu: Control

func _ready() -> void:
	add_to_group("Player")
	checkpoint_position = global_position
	spawn.play()

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Tambahkan PauseMenu ke scene
	pause_menu = pause_menu_scene.instantiate()
	get_tree().current_scene.call_deferred("add_child", pause_menu)
	pause_menu.z_index = 100
	pause_menu.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not pause_menu.visible:
		get_tree().paused = true
		var pause_position = camera.global_position + Vector2(20, 20)
		pause_menu.show_menu(pause_position)

func _physics_process(delta: float) -> void:
	was_in_air = not is_on_floor()

	if velocity.x != 0:
		player_ui.animation = "run"
	else:
		player_ui.animation = "idle"

	if not is_on_floor():
		velocity += get_gravity() * delta
		player_ui.animation = "jump"

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump.play()

	var direction := Input.get_axis("wasd_left", "wasd_right")
	if direction:
		player_ui.flip_h = direction < 0
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# --- Checkpoint & Respawn ---
func set_checkpoint(position: Vector2) -> void:
	checkpoint_position = position
	show_checkpoint_message()

func respawn() -> void:
	global_position = checkpoint_position

func show_checkpoint_message() -> void:
	if checkpoint_label == null:
		return

	if not checkpoint_label.is_inside_tree():
		await checkpoint_label.ready
		if not checkpoint_label.is_inside_tree():
			return

	checkpoint_label.text = "Checkpoint Telah Diambil!"
	checkpoint_label.visible = true
	checkpoint_label.add_theme_font_override("font", preload("res://assets/font pixel/GrapeSoda.ttf"))
	checkpoint_label.global_position = camera.global_position - (checkpoint_label.size / 2)

	var tween = checkpoint_label.create_tween()
	checkpoint_label.modulate.a = 0
	tween.tween_property(checkpoint_label, "modulate:a", 1, 0.5)
	await tween.finished

	if not checkpoint_label.is_inside_tree():
		return

	tween = checkpoint_label.create_tween()
	tween.tween_property(checkpoint_label, "modulate:a", 0, 0.5)
	await tween.finished

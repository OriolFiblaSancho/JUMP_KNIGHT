extends Control

var is_muted = false
var is_paused = false

func _ready():
	# Oculta el menú de pausa al iniciar
	visible = false
	# Asegura que el juego comienza sin pausar
	get_tree().paused = false
	
	# Configurar el anclaje para centralizar el menú
	anchor_right = 1
	anchor_bottom = 1
	grow_horizontal = 2
	grow_vertical = 2

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC
		toggle_pause()

func toggle_pause():
	is_paused = !is_paused
	
	if is_paused:
		# Pausar el juego
		get_tree().paused = true
		# Mostrar el menú de pausa y centrarlo
		visible = true
		center_to_player_camera()
	else:
		# Reanudar el juego
		get_tree().paused = false
		# Ocultar el menú de pausa
		visible = false

# Función para centrar el menú respecto a la cámara del jugador
func center_to_player_camera():
	# Buscar al jugador en la escena actual
	var player = get_tree().get_nodes_in_group("player")
	if player.size() > 0:
		player = player[0]  # Tomar el primer jugador si hay varios
	else:
		# Si no está en un grupo, buscar por tipo
		player = get_tree().get_first_node_in_group("player")
		if not player:
			player = get_node_or_null("/root/Game/Player")  # Intenta un camino específico
	
	if player:
		# Acceder a la cámara del jugador
		var player_camera = player.get_node_or_null("Camera2D")
		
		if player_camera:
			# Tener en cuenta el offset de la cámara
			var camera_offset = player_camera.offset
			var viewport_rect = get_viewport_rect()
			
			# Calcular la posición global del centro de la vista
			# Ajustando según el offset de la cámara
			var global_camera_pos = player_camera.get_screen_center_position()
			
			# Establecer el menú para que esté centrado en la vista de la cámara
			# Esto debe ser usado si el menú es un CanvasLayer o UI element
			# que no se desplaza con la cámara
			global_position = global_camera_pos - (size / 2)
			
			# Ajustar por el offset de la cámara si es necesario
			# global_position -= camera_offset
	else:
		# Si no se encuentra la cámara, centrar en la pantalla
		position = get_viewport_rect().size / 2 - size / 2

# Asegúrate de que el menú de pausa tenga un nombre y un grupo
func _enter_tree():
	add_to_group("pause_menu")
	name = "PauseMenu"

# Tus funciones existentes
func _on_mute_pressed() -> void:
	is_muted = !is_muted
	
	if is_muted:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		
func _on_reload_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

func _on_play_pressed() -> void:
	toggle_pause()

func _on_exit_pressed() -> void:
	get_tree().quit()

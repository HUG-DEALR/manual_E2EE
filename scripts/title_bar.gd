extends PanelContainer

@onready var full_screen_button: Button = $aux_buttons/FullScreen

var previous_window_position: Vector2i = Vector2i.ZERO
var previous_window_size: Vector2i = Vector2i.ZERO
var is_maximized: bool = false

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_full_screen_pressed() -> void:
	var screen: int = DisplayServer.window_get_current_screen()
	var usable_rect: Rect2i = DisplayServer.screen_get_usable_rect(screen)
	
	if not is_maximized:
		previous_window_position = DisplayServer.window_get_position()
		previous_window_size = DisplayServer.window_get_size()
		
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_position(usable_rect.position)
		DisplayServer.window_set_size(usable_rect.size)
		
		is_maximized = true
		
		full_screen_button.text = "⿻"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_position(previous_window_position)
		DisplayServer.window_set_size(previous_window_size)
		
		is_maximized = false
		full_screen_button.text = "🗖"

func _on_minimise_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)

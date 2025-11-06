extends Node2D


func _on_new_button_pressed() -> void:
	SaveManager.remove_save_file()
	_on_load_button_pressed()

func _on_load_button_pressed() -> void:
	SaveManager.format_check()
	get_tree().change_scene_to_file("res://src/game.tscn")

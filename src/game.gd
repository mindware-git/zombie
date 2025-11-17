extends Node2D

@onready var time_label = $CanvasLayer/VBoxContainer/HBoxContainer/TimeLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_label.text = "Time: " + str(SaveManager.game_data.running_time)

func _on_timer_timeout() -> void:
	SaveManager.game_data.running_time += 1
	time_label.text = "Time: " + str(SaveManager.game_data.running_time)

extends Node2D

@onready var time_label = $CanvasLayer/VBoxContainer/HBoxContainer/TimeLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_label.text = "Time: " + str(SaveManager.game_data.running_time)
	if not SaveManager.game_data.generator_powered:
		$CanvasModulate.color = Color(0.5, 0.5, 0.5, 1)

func _on_timer_timeout() -> void:
	SaveManager.game_data.running_time += 1
	time_label.text = "Time: " + str(SaveManager.game_data.running_time)

func _on_detect_range_body_entered(body: Node2D) -> void:
	body.interact_entered("radio")


func _on_detect_range_body_exited(body: Node2D) -> void:
	body.interact_exited()


func _on_save_zone_body_entered(body: Node2D) -> void:
	print("Saved!")
	SaveManager.save_game()


func _on_guard_detect_range_body_entered(body: Node2D) -> void:
	body.interact_entered("guard")


func _on_guard_detect_range_body_exited(body: Node2D) -> void:
	body.interact_exited()


func _on_door_detect_range_body_entered(body: Node2D) -> void:
	body.interact_entered("door")


func _on_door_detect_range_body_exited(body: Node2D) -> void:
	body.interact_exited()


func _on_generator_detect_range_body_entered(body: Node2D) -> void:
	body.interact_entered("generator")


func _on_generator_detect_range_body_exited(body: Node2D) -> void:
	body.interact_exited()

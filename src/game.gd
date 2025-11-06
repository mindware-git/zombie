extends Node2D

@onready var time_label = $CanvasLayer/VBoxContainer/HBoxContainer/TimeLabel
@onready var money_label = $CanvasLayer/VBoxContainer/HBoxContainer/MoneyLabel
@onready var restaurant_node = $RestaurantNode
@onready var chef_node = $ChefNode
@onready var chef_canvas = $ChefNode/CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_label.text = "Time: " + str(SaveManager.game_data.running_time)
	money_label.text = "Money: " + str(SaveManager.game_data.money) + "$"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if SaveManager.game_data.money > 1000:
		get_tree().change_scene_to_file("res://src/ending.tscn")


func _on_timer_timeout() -> void:
	SaveManager.game_data.running_time += 1
	time_label.text = "Time: " + str(SaveManager.game_data.running_time)

func _on_restaurant_button_pressed() -> void:
	restaurant_node.show()
	chef_node.hide()
	chef_canvas.hide()

func _on_chef_button_pressed() -> void:
	restaurant_node.hide()
	chef_node.show()
	chef_canvas.show()

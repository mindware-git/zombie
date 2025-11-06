extends Node2D


@export var rice_amount: float
var ingredients: Array[Ingredient] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("sushi ready")
	print("initial rice amount: " + str(rice_amount))

	var rice = load("res://src/entity/rice.tres")
	ingredients.append(rice)
	for i in range(ingredients.size()):
		var entity = ingredients[i]
		var sprite = Sprite2D.new()
		sprite.texture = entity.texture
		add_child(sprite)

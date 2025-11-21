extends Area2D

var speed: float = 600.0
var direction: Vector2
var damage: int

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body is not Player and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()


func _on_area_entered(_area: Area2D) -> void:
	queue_free()

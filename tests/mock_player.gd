extends Node2D
class_name MockPlayer

# Mock Player를 위한 변수들
var damage_received: int = 0
var max_hp: int = 100
var current_hp: int = 100

# take_damage 메서드 구현 (테스트용)
func take_damage(amount: int) -> void:
	damage_received += amount

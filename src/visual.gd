extends Control

func _ready():
	# Control 크기 설정 - 더 크게 만들어서 클릭하기 쉽게
	size = Vector2(100, 100)
	
	# ColorRect 추가하여 시각적 피드백 제공 (마우스 이벤트는 받지 않도록 설정)
	var color_rect = ColorRect.new()
	color_rect.size = size
	color_rect.color = Color(1, 0, 0, 0.5)  # 반투명 빨간색
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 마우스 이벤트 무시
	add_child(color_rect)

func _get_drag_data(at_position: Vector2) -> Variant:
	print("drag at")
	print(at_position)

	var preview_textrue = TextureRect.new()
	var ingredient: Ingredient = load("res://src/entity/rice.tres")
	preview_textrue.texture = ingredient.texture

	var preview = Control.new()
	preview.add_child(preview_textrue)

	set_drag_preview(preview)
	# return entity id 1
	return 1

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	print("can drop at ")
	print(at_position)
	print(data)
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	print("drop data at")
	print(at_position)
	print(data)

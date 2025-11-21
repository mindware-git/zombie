extends StaticBody2D

@export var detect_range: int
@export var interact_type: String = "" # "radio", "door", "generator", "guard"
@export var entity_texture: Texture2D

var current_player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 텍스처가 있다면 Sprite2D에 적용
	if entity_texture:
		var sprite = get_node_or_null("Sprite2D")
		if sprite:
			sprite.texture = entity_texture
	
	# 기존 DetectRange 노드가 있다면 시그널 연결
	var detect_range_node = get_node_or_null("DetectRange")
	if detect_range_node:
		detect_range_node.body_entered.connect(_on_detect_range_body_entered)
		detect_range_node.body_exited.connect(_on_detect_range_body_exited)

# DetectRange에 플레이어가 들어왔을 때
func _on_detect_range_body_entered(body: Node2D):
	if body is Player:
		current_player = body
		body.interact_entered(interact_type)

# DetectRange에서 플레이어가 나갔을 때
func _on_detect_range_body_exited(body: Node2D):
	if body is Player:
		current_player = null
		body.interact_exited()

# # 상호작용 실행
# func interact():
# 	if not current_player:
# 		return
	
# 	match interact_type:
# 		"radio":
# 			interact_radio()
# 		"door":
# 			interact_door()
# 		"generator":
# 			interact_generator()
# 		"guard":
# 			interact_guard()
# 		_:
# 			print("알 수 없는 상호작용 타입: ", interact_type)

# # 라디오 상호작용
# func interact_radio():
# 	current_player.show_dialogue("라디오를 켰습니다.")

# # 문 상호작용
# func interact_door():
# 	var key_item = load("res://src/entity/item/key.tres")
# 	if SaveManager.game_data.owned_entities.has(key_item):
# 		# 문 열기 - 자기 자신을 제거
# 		queue_free()
# 		current_player.show_dialogue("문이 열렸습니다!")
# 	else:
# 		current_player.show_dialogue("문이 잠겨있습니다. Key가 필요합니다.")

# # 발전기 상호작용
# func interact_generator():
# 	var canvas_modulate = get_tree().current_scene.get_node("CanvasModulate")
# 	if SaveManager.game_data.generator_powered:
# 		# Generator 끄기
# 		SaveManager.game_data.generator_powered = false
# 		canvas_modulate.color = Color(0.3, 0.3, 0.3, 1.0) # 어둡게
# 		current_player.show_dialogue("발전기를 껐습니다.")
# 	else:
# 		# Generator 켜기
# 		SaveManager.game_data.generator_powered = true
# 		canvas_modulate.color = Color.WHITE # 밝게
# 		current_player.show_dialogue("발전기를 켰습니다. 건물 전체에 불이 들어옵니다!")

# # 가드 상호작용
# func interact_guard():
# 	current_player.get_node("CanvasLayer/AttackButton").show()
# 	var key_item = load("res://src/entity/item/key.tres")
# 	if not SaveManager.game_data.owned_entities.has(key_item):
# 		SaveManager.game_data.owned_entities.append(key_item)
# 		current_player.show_dialogue("아이템 Key를 획득")
# 	else:
# 		current_player.show_dialogue("이미 Key를 획득했습니다")

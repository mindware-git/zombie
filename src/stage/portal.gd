extends Area2D

@export var destination_scene: PackedScene

func _on_body_entered(body: Node2D) -> void:
	if body is Player: # 플레이어만 포털 사용 가능
		if destination_scene:
			print("Stage를 이동합니다.")
			# 모든 스테이지 전환 로직을 다음 프레임으로 지연
			call_deferred("_change_stage")
		else:
			print("목적지 씬이 설정되지 않았습니다!")

func _change_stage():
	# Stage 노드 찾기
	var stage_node = find_stage_node()
	if stage_node:
		# 새로운 스테이지 먼저 추가
		var new_stage = destination_scene.instantiate()
		stage_node.add_child(new_stage)
		
		# 플레이어 위치 초기화
		var player = get_tree().get_first_node_in_group("player")
		if player:
			reset_player_position(player)
		
		_clear_existing_stages(stage_node)
	else:
		print("Stage 노드를 찾을 수 없습니다!")

func find_stage_node() -> Node:
	# 포탈 -> 상위 노드들을 탐색하여 Stage 노드 찾기
	var current = get_parent()
	while current:
		if current.name == "Stage":
			return current
		current = current.get_parent()
	return null

func _clear_existing_stages(stage_node: Node):
	# 새로 추가된 스테이지를 제외한 기존 스테이지들만 제거
	var children = stage_node.get_children()
	# 마지막 자식(새로 추가된 스테이지)을 제외하고 모두 제거
	for i in range(children.size() - 1):
		children[i].queue_free()

func reset_player_position(player: Player):
	# 플레이어 위치를 초기 위치로 리셋
	player.global_position = Vector2.ZERO

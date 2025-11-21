extends BaseCharacter
class_name Player

enum WeaponType {FIST, GUN}

var bullet_scene = preload("res://src/entity/bullet.tscn")

var current_interact_id: String
var max_stamina: int = 100
var current_stamina: int = 100
var attack_stamina_cost: int = 10
var current_weapon: WeaponType = WeaponType.FIST
var last_non_zero_direction: Vector2 = Vector2.UP # 기본값은 위쪽

@onready var inventory_ui = $CanvasLayer/InventoryUI

func _ready():
	super._ready()
	global_position = SaveManager.game_data.position
	update_hp_bar()
	update_stamina_bar()

	create_inventory()

	update_weapon(WeaponType.GUN)
	$CanvasLayer/AttackButton.show()

func _process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		last_non_zero_direction = direction
	current_direction = direction.normalized()
	velocity = direction * delta * 20000
	update_sprite_direction()

	# 공격 쿨타임 업데이트
	if attack_timer > 0:
		attack_timer -= delta

	move_and_slide()

func update_weapon(type: WeaponType):
	if type == WeaponType.GUN:
		current_weapon = WeaponType.GUN
		attack_range = 200
		attack_cooltime = 0.1
		attack_damage = 50
		attack_stamina_cost = 1
	else:
		current_weapon = WeaponType.FIST
		attack_range = 50
		attack_cooltime = 5
		attack_damage = 5

func interact_entered(interact_id: String):
	current_interact_id = interact_id
	print(current_interact_id)
	$CanvasLayer/InteractButton.show()


func interact_exited():
	$CanvasLayer/InteractButton.hide()
	$CanvasLayer/DialogueLabel.hide()

func interact():
	if current_interact_id == "radio":
		$CanvasLayer/DialogueLabel.text = "라디오를 켰습니다."
		$CanvasLayer/DialogueLabel.show()
	elif current_interact_id == "guard":
		$CanvasLayer/AttackButton.show()
		$CanvasLayer/AttackButton.show()
		var key_item = load("res://src/entity/item/key.tres")
		if not SaveManager.game_data.owned_entities.has(key_item):
			SaveManager.game_data.owned_entities.append(key_item)
			$CanvasLayer/DialogueLabel.text = "아이템 Key를 획득"
		else:
			$CanvasLayer/DialogueLabel.text = "이미 Key를 획득했습니다"
		$CanvasLayer/DialogueLabel.show()
	elif current_interact_id == "door":
		var key_item = load("res://src/entity/item/key.tres")
		if SaveManager.game_data.owned_entities.has(key_item):
			# 문 열기 로직 - 게임 씬의 문 노드 찾기
			var door_node = get_tree().current_scene.get_node("Door")
			if door_node:
				door_node.queue_free()
				$CanvasLayer/DialogueLabel.text = "문이 열렸습니다!"
			else:
				$CanvasLayer/DialogueLabel.text = "문을 찾을 수 없습니다."
		else:
			$CanvasLayer/DialogueLabel.text = "문이 잠겨있습니다. Key가 필요합니다."
		$CanvasLayer/DialogueLabel.show()
	elif current_interact_id == "generator":
		# Generator 토글 로직
		var canvas_modulate = get_tree().current_scene.get_node("CanvasModulate")
		if SaveManager.game_data.generator_powered:
			# Generator 끄기
			SaveManager.game_data.generator_powered = false
			canvas_modulate.color = Color(0.3, 0.3, 0.3, 1.0) # 어둡게
			$CanvasLayer/DialogueLabel.text = "발전기를 껐습니다."
		else:
			# Generator 켜기
			SaveManager.game_data.generator_powered = true
			canvas_modulate.color = Color.WHITE # 밝게
			$CanvasLayer/DialogueLabel.text = "발전기를 켰습니다. 건물 전체에 불이 들어옵니다!"
		$CanvasLayer/DialogueLabel.show()
	elif current_interact_id == "door_lock":
		print("Door lock")
		# door lock UI popup.
		$CanvasLayer/DoorLockUI.show()
	$CanvasLayer/InteractButton.hide()

func _on_interact_button_pressed() -> void:
	interact()


func _on_attack_button_pressed() -> void:
	if current_stamina >= attack_stamina_cost and attack_timer <= 0:
		current_stamina -= attack_stamina_cost
		update_stamina_bar()
		execute_player_attack()
	else:
		if current_stamina < attack_stamina_cost:
			# 스테미나 부족 메시지
			$CanvasLayer/DialogueLabel.text = "스테미나가 부족합니다!"
			$CanvasLayer/DialogueLabel.show()
		else:
			# 쿨타임 메시지
			$CanvasLayer/DialogueLabel.text = "공격 쿨타임입니다!"
			$CanvasLayer/DialogueLabel.show()

func find_nearest_enemy() -> Enemy:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var nearest_enemy: Enemy = null
	var nearest_distance = attack_range
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance <= attack_range and distance < nearest_distance:
			# RayCast2D로 시선 확인
			raycast.target_position = (enemy.global_position - global_position).normalized() * attack_range
			raycast.force_raycast_update()
			
			if not raycast.is_colliding() or raycast.get_collider() == enemy:
				nearest_enemy = enemy
				nearest_distance = distance
	
	return nearest_enemy

func execute_player_attack():
	if current_weapon == WeaponType.GUN:
		# 적이 없어도 RAYCast2D로 발사.
		var bullet = bullet_scene.instantiate()

		bullet.global_position = global_position
		bullet.direction = last_non_zero_direction.normalized()
		bullet.damage = attack_damage
		
		# 씬에 추가
		get_tree().current_scene.add_child(bullet)
		attack_timer = attack_cooltime
		return
	
	var nearest_enemy = find_nearest_enemy()
	if nearest_enemy:
		target = nearest_enemy
		
		# RayCast2D로 타겟 조준
		var direction = (target.global_position - global_position).normalized()
		raycast.target_position = direction * attack_range
		
		# 타겟이 공격 가능한지 확인
		if target.has_method("take_damage"):
			target.take_damage(attack_damage)
			attack_timer = attack_cooltime
			print("적을 공격했습니다! 데미지: ", attack_damage)
		else:
			print("타겟이 공격 가능하지 않습니다.")
	else:
		print("공격 범위에 적이 없습니다.")


func create_inventory():
	var main_container = $CanvasLayer/InventoryUI/MainContainer
	main_container.position = Vector2(100, 100)
	main_container.size = Vector2(600, 400)

	var title_label = $CanvasLayer/InventoryUI/MainContainer/TitleLabel
	title_label.text = "인벤토리"
	title_label.add_theme_font_size_override("font_size", 24)

	# 아이템 그리드
	var grid_container = $CanvasLayer/InventoryUI/MainContainer/GridContainer
	grid_container.columns = 5
	grid_container.size = Vector2(580, 300)
	
	# 슬롯 20개 생성 (빈 슬롯으로만 생성)
	var template_button = $CanvasLayer/TemplateButton
	for i in range(20):
		var slot = template_button.duplicate()
		slot.show()
		slot.custom_minimum_size = Vector2(50, 50)
		
		# 슬롯 클릭 이벤트 연결
		slot.pressed.connect(_on_slot_clicked.bind(i))
		
		grid_container.add_child(slot)

func update_inventory():
	var grid_container = $CanvasLayer/InventoryUI/MainContainer/GridContainer
	var slots = grid_container.get_children()
	
	# 기존 슬롯들의 내용 업데이트
	for i in range(20):
		if i < slots.size():
			var slot = slots[i] as TextureButton
			
			# 소유한 아이템이 있으면 표시
			if i < SaveManager.game_data.owned_entities.size():
				slot.modulate = Color(0.6, 0.4, 0.2, 0.8) # 아이템이 있는 슬롯 색상
			else:
				slot.modulate = Color(0.3, 0.3, 0.3, 0.8) # 빈 슬롯 색상

func _on_inventory_button_pressed() -> void:
	get_tree().paused = true
	update_inventory()
	inventory_ui.show()
	$"CanvasLayer/Virtual Joystick".hide()

func _on_slot_clicked(slot_index: int) -> void:
	# 아이템이 있는 슬롯만 클릭 가능
	if slot_index < SaveManager.game_data.owned_entities.size():
		var item_detail_scene = preload("res://src/entity/character/item_detail.tscn")
		var item_detail = item_detail_scene.instantiate()
		$CanvasLayer.add_child(item_detail)

func _on_close_button_pressed() -> void:
	get_tree().paused = false
	inventory_ui.hide()
	$"CanvasLayer/Virtual Joystick".show()

func take_damage(amount: int) -> void:
	super.take_damage(amount)
	update_hp_bar()
	
	if current_hp <= 0:
		get_tree().change_scene_to_file("res://src/ending.tscn")

func update_hp_bar():
	var hp_percentage = float(current_hp) / float(max_hp) * 100.0
	$CanvasLayer/VBoxContainer/HPBar.value = hp_percentage

func update_stamina_bar():
	var stamina_percentage = float(current_stamina) / float(max_stamina) * 100.0
	$CanvasLayer/VBoxContainer/StaminaBar.value = stamina_percentage


func _on_lock_close_button_pressed() -> void:
	$CanvasLayer/DoorLockUI.hide()

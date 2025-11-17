extends BaseCharacter
class_name Player

## 플레이어 전용 시그널
#signal weapon_equipped(weapon: WeaponResource)
#signal weapon_unequipped()
#signal item_picked_up(item: ItemResource)
#signal skill_used(skill: SkillResource)
#signal stamina_changed(current_stamina: int, max_stamina: int)
#signal experience_gained(amount: int)
#signal level_up(new_level: int)
#

@export var max_stamina: int = 100
#@export var stamina_regen_rate: float = 10.0 # 초당 스테미나 회복량
#@export var current_level: int = 1
#@export var current_experience: int = 0
#@export var experience_to_next_level: int = 100
#
## 입력 관련
#var input_vector: Vector2 = Vector2.ZERO
#var is_sprinting: bool = false
#var sprint_stamina_cost: float = 20.0 # 초당 소모 스테미나

var current_stamina: int
#var current_weapon: WeaponResource = null
#var is_attacking: bool = false
#var attack_cooldown: float = 0.0

## 컴포넌트 참조
#var camera: Camera2D
#var interaction_area: Area2D
#var light: PointLight2D if Engine.has_singleton("PointLight2D") else null

func _ready():
	super._ready()
	#
	## 스테미나 초기화
	#current_stamina = max_stamina
	#
	## 컴포넌트 참조 가져오기
	#camera = $Camera2D
	#interaction_area = $InteractionArea
	#if has_node("PointLight2D"):
		#light = $PointLight2D
	#
	## 컴포넌트 설정
	#setup_components()
	#
	## 상태 시그널 연결
	#health_changed.connect(_on_health_changed)
#

func _process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * delta * movement_speed
	move_and_slide()

## 컴포넌트 설정
#func setup_components():
	## 카메라 설정
	#if camera:
		#camera.enabled = true
	#
	## 상호작용 영역 설정
	#if interaction_area:
		#interaction_area.body_entered.connect(_on_interaction_area_entered)
		#interaction_area.body_exited.connect(_on_interaction_area_exited)
	#
	## 라이트 설정
	#if light:
		#light.enabled = false
#
## 입력 처리
#func _unhandled_input(event):
	#if not is_alive or is_stunned:
		#return
	#
	## 이동 입력 처리
	#handle_movement_input(event)
	#
	## 액션 입력 처리
	#handle_action_input(event)
#
## 이동 입력 처리
#func handle_movement_input(event):
	## 키보드 입력
	#if event is InputEventKey:
		#input_vector = Vector2.ZERO
		#if Input.is_action_pressed("move_up"):
			#input_vector.y -= 1
		#if Input.is_action_pressed("move_down"):
			#input_vector.y += 1
		#if Input.is_action_pressed("move_left"):
			#input_vector.x -= 1
		#if Input.is_action_pressed("move_right"):
			#input_vector.x += 1
		#
		## 달리기 입력
		#is_sprinting = Input.is_action_pressed("sprint")
	#
	## 조이스틱 입력 (모바일)
	#elif event is InputEventJoypadMotion:
		#input_vector.x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		#input_vector.y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
#
## 액션 입력 처리
#func handle_action_input(event):
	#if event.is_action_pressed("attack"):
		#perform_attack()
	#elif event.is_action_pressed("interact"):
		#interact()
	#elif event.is_action_pressed("use_item"):
		#use_current_item()
	#elif event.is_action_pressed("toggle_light"):
		#toggle_light()
#
## 물리 업데이트
#func _physics_process(delta):
	#super._physics_process(delta)
	#
	#if not is_alive:
		#return
	#
	## 입력 처리
	#update_input()
	#
	## 스테미나 업데이트
	#update_stamina(delta)
	#
	## 공격 쿨다운 업데이트
	#update_attack_cooldown(delta)
#
## 입력 업데이트
#func update_input():
	## 이동 방향 설정
	#set_movement_direction(input_vector)
	#
	## 달리기 속도 조정
	#if is_sprinting and current_stamina > 0:
		#movement_speed = 150.0 # 달리기 속도
	#else:
		#movement_speed = 100.0 # 기본 속도
#
## 스테미나 업데이트
#func update_stamina(delta: float):
	#if is_sprinting and current_stamina > 0:
		## 달리기 시 스테미나 소모
		#current_stamina = max(0, current_stamina - int(sprint_stamina_cost * delta))
	#elif current_stamina < max_stamina:
		## 회복
		#current_stamina = min(max_stamina, current_stamina + int(stamina_regen_rate * delta))
	#
	#stamina_changed.emit(current_stamina, max_stamina)
#
## 공격 쿨다운 업데이트
#func update_attack_cooldown(delta: float):
	#if attack_cooldown > 0:
		#attack_cooldown -= delta
		#if attack_cooldown <= 0:
			#attack_cooldown = 0
			#is_attacking = false
#
## 이동 처리 오버라이드
#func handle_movement(delta: float):
	#super.handle_movement(delta)
	#
	## 애니메이션 업데이트
	#update_animation()
#
## 애니메이션 업데이트
#func update_animation():
	#if not animation_player:
		#return
	#
	#var anim_name = "idle"
	#
	#if is_attacking:
		#anim_name = "attack"
	#elif input_vector.length() > 0.1:
		#if is_sprinting:
			#anim_name = "run"
		#else:
			#anim_name = "walk"
	#
	#if animation_player.has_animation(anim_name):
		#if animation_player.current_animation != anim_name:
			#animation_player.play(anim_name)
#
## 공격 수행
#func perform_attack():
	#if is_attacking or not current_weapon:
		#return
	#
	#is_attacking = true
	#attack_cooldown = 1.0 / current_weapon.fire_rate
	#
	## 공격 애니메이션
	#if animation_player and animation_player.has_animation("attack"):
		#animation_player.play("attack")
	#
	## 공격 로직
	#execute_attack()
#
## 공격 실행
#func execute_attack():
	## 공격 범위 내의 적 탐지
	#var attack_range = current_weapon.range
	#var targets = get_targets_in_range(attack_range)
	#
	#for target in targets:
		#if target is BaseCharacter and target != self:
			#var damage = calculate_damage()
			#if target.take_damage(damage, self):
				#damage_dealt.emit(target, damage)
#
## 공격 범위 내의 타겟 가져오기
#func get_targets_in_range(range: float) -> Array:
	#var targets = []
	#var space_state = get_world_2d().direct_space_state
	#var query = PhysicsShapeQueryParameters2D.new()
	#
	## 원형 충돌 모양 생성
	#var circle_shape = CircleShape2D.new()
	#circle_shape.radius = range
	#
	#query.shape = circle_shape
	#query.transform = Transform2D(0, global_position)
	#query.collision_mask = 2 # 적 레이어
	#query.exclude = [self]
	#
	#var results = space_state.intersect_shape(query)
	#for result in results:
		#if result.collider:
			#targets.append(result.collider)
	#
	#return targets
#
## 데미지 계산
#func calculate_damage() -> int:
	#if not current_weapon:
		#return 10 # 기본 데미지
	#
	#var base_damage = current_weapon.damage
	#
	## 크리티컬 확률 (10%)
	#if randf() < 0.1:
		#base_damage *= 2
	#
	#return base_damage
#
## 무기 장착
#func equip_weapon(weapon: WeaponResource):
	#if current_weapon:
		#unequip_weapon()
	#
	#current_weapon = weapon
	#weapon_equipped.emit(weapon)
	#
	#print("Weapon equipped: ", weapon.name)
#
## 무기 해제
#func unequip_weapon():
	#if current_weapon:
		#current_weapon = null
		#weapon_unequipped.emit()
		#print("Weapon unequipped")
#
## 상호작용
#func interact():
	#var interactables = get_interactables()
	#if interactables.size() > 0:
		#var nearest = get_nearest_interactable(interactables)
		#if nearest.has_method("interact"):
			#nearest.interact(self)
#
## 상호작용 가능한 오브젝트 가져오기
#func get_interactables() -> Array:
	#var objects = []
	#if interaction_area:
		#for body in interaction_area.get_overlapping_bodies():
			#if body.has_method("interact"):
				#objects.append(body)
	#return objects
#
## 가장 가까운 상호작용 오브젝트 가져오기
#func get_nearest_interactable(objects: Array):
	#var nearest = null
	#var nearest_distance = INF
	#
	#for obj in objects:
		#var distance = global_position.distance_to(obj.global_position)
		#if distance < nearest_distance:
			#nearest_distance = distance
			#nearest = obj
	#
	#return nearest
#
## 현재 아이템 사용
#func use_current_item():
	## 인벤토리 시스템과 연동 필요
	#pass
#
## 라이트 토글
#func toggle_light():
	#if light:
		#light.enabled = not light.enabled
		#print("Light toggled: ", light.enabled)
#
## 경험치 획득
#func gain_experience(amount: int):
	#current_experience += amount
	#experience_gained.emit(amount)
	#
	## 레벨 업 체크
	#while current_experience >= experience_to_next_level:
		#level_up()
#
## 레벨 업
#func level_up():
	#current_experience -= experience_to_next_level
	#current_level += 1
	#experience_to_next_level = calculate_experience_for_next_level()
	#
	## 스탯 증가
	#max_health += 20
	#current_health = max_health
	#max_stamina += 10
	#current_stamina = max_stamina
	#
	#level_up.emit(current_level)
	#print("Level up! Current level: ", current_level)
#
## 다음 레벨所需 경험치 계산
#func calculate_experience_for_next_level() -> int:
	#return int(100 * pow(1.5, current_level - 1))
#
## === 오버라이드된 가상 함수 ===
#
## 데미지를 받았을 때
#func on_damage_taken(amount: int, attacker: BaseCharacter):
	#super.on_damage_taken(amount, attacker)
	#
	## 플레이어 전용 피격 효과
	#if camera:
		#camera.shake(0.2, 5) # 카메라 흔들기
#
## 사망했을 때
#func on_death():
	#super.on_death()
	#
	## 플레이어 사망 처리
	#if camera:
		#camera.enabled = false
	#
	## 게임 오버 신호
	#GameManager.game_over()
#
## === 시그널 핸들러 ===
#
## 체력 변경 시
#func _on_health_changed(current: int, maximum: int):
	## HUD 업데이트
	#if GameManager.hud:
		#GameManager.hud.update_health_bar(current, maximum)
#
## 상호작용 영역 진입
#func _on_interaction_area_entered(body):
	#if body.has_method("interact"):
		## 상호작용 가능 표시
		#print("Can interact with: ", body.name)
#
## 상호작용 영역 퇴장
#func _on_interaction_area_exited(body):
	#if body.has_method("interact"):
		## 상호작용 불가능 표시
		#print("Cannot interact with: ", body.name)
#
## === 유틸리티 함수 ===
#
## 플레이어 정보 출력
#func print_player_info():
	#print("=== Player Info ===")
	#print("Level: ", current_level)
	#print("Experience: ", current_experience, "/", experience_to_next_level)
	#print("Health: ", current_health, "/", max_health)
	#print("Stamina: ", current_stamina, "/", max_stamina)
	#print("Weapon: ", current_weapon.name if current_weapon else "None")
	#print("==================")
#
## 플레이어 데이터 저장 (GameDataResource용)
#func get_player_data() -> Dictionary:
	#return {
		#"level": current_level,
		#"experience": current_experience,
		#"health": current_health,
		#"max_health": max_health,
		#"stamina": current_stamina,
		#"max_stamina": max_stamina,
		#"position": global_position,
		#"current_weapon_id": current_weapon.id if current_weapon else ""
	#}
#
## 플레이어 데이터 로드
#func load_player_data(data: Dictionary):
	#current_level = data.get("level", 1)
	#current_experience = data.get("experience", 0)
	#current_health = data.get("health", max_health)
	#max_health = data.get("max_health", 100)
	#current_stamina = data.get("stamina", max_stamina)
	#max_stamina = data.get("max_stamina", 100)
	#global_position = data.get("position", Vector2.ZERO)
	#
	## 무기 로드 (인벤토리 시스템과 연동 필요)
	#var weapon_id = data.get("current_weapon_id", "")
	#if weapon_id != "":
		## InventoryManager에서 무기 찾아 장착
		#pass

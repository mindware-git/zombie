extends GutTest

var enemy: Enemy
var test_player: Player

func before_each():
	# Enemy 생성
	enemy = Enemy.new()
	
	# Enemy의 필수 컴포넌트 설정 (테스트를 위해)
	var detect_range = Area2D.new()
	detect_range.name = "DetectRange"
	enemy.add_child(detect_range)
	
	var raycast = RayCast2D.new()
	raycast.name = "RayCast2D"
	enemy.add_child(raycast)
	
	var animated_sprite = AnimatedSprite2D.new()
	animated_sprite.name = "AnimatedSprite2D"
	enemy.add_child(animated_sprite)
	
	add_child_autofree(enemy)
	
	# Player 씬에서 instantiate
	var player_scene = load("res://src/entity/character/player.tscn")
	test_player = player_scene.instantiate()
	test_player.name = "TestPlayer"
	add_child_autofree(test_player)

func test_enemy_initialization():
	# Enemy가 올바르게 초기화되는지 테스트
	assert_eq(enemy.current_state, Enemy.EnemyState.IDLE, "초기 상태는 IDLE이어야 함")
	assert_eq(enemy.current_hp, enemy.max_hp, "초기 HP는 최대 HP여야 함")
	assert_true(enemy.is_in_group("enemy"), "enemy 그룹에 속해야 함")
	assert_false(enemy.player_detected, "초기에는 플레이어를 감지하지 않아야 함")
	assert_eq(enemy.target, null, "초기 타겟은 null이어야 함")

func test_state_transition_idle_to_chase():
	# IDLE → CHASE 상태 변화 테스트
	enemy.current_state = Enemy.EnemyState.IDLE
	enemy._on_detect_range_body_entered(test_player)
	
	assert_eq(enemy.current_state, Enemy.EnemyState.CHASE, "플레이어 감지 시 CHASE 상태로 변경되어야 함")
	assert_true(enemy.player_detected, "플레이어 감지 상태가 true여야 함")
	assert_eq(enemy.target, test_player, "타겟이 설정되어야 함")

func test_state_transition_chase_to_idle():
	# CHASE → IDLE 상태 변화 테스트
	enemy.current_state = Enemy.EnemyState.CHASE
	enemy.player_detected = true
	enemy.target = test_player
	
	enemy._on_detect_range_body_exited(test_player)
	
	assert_eq(enemy.current_state, Enemy.EnemyState.IDLE, "플레이어 감지 해제 시 IDLE 상태로 변경되어야 함")
	assert_false(enemy.player_detected, "플레이어 감지 상태가 false여야 함")
	assert_eq(enemy.target, null, "타겟이 해제되어야 함")

func test_attack_functionality():
	# 공격 기능 테스트
	enemy.current_state = Enemy.EnemyState.ATTACK
	enemy.target = test_player
	enemy.attack_timer = 0.0 # 쿨타임 초기화
	enemy.global_position = Vector2(0, 0)
	test_player.global_position = Vector2(50, 0) # 공격 범위 내
	
	var initial_hp = test_player.current_hp
	
	# 공격 실행
	enemy._handle_attack_state(0.1)
	
	assert_gt(enemy.attack_timer, 0.0, "공격 후 쿨타임이 설정되어야 함")
	assert_eq(test_player.current_hp, initial_hp - 20, "타겟이 20의 데미지를 받아야 함")

func test_attack_cooldown():
	# 공격 쿨타임 테스트
	enemy.current_state = Enemy.EnemyState.ATTACK
	enemy.target = test_player
	enemy.attack_timer = enemy.attack_cooltime # 쿨타임 상태
	enemy.global_position = Vector2(0, 0)
	test_player.global_position = Vector2(50, 0)
	
	var initial_hp = test_player.current_hp
	
	# 쿨타임 중에는 공격하지 않아야 함
	enemy._handle_attack_state(0.1)
	
	assert_eq(test_player.current_hp, initial_hp, "쿨타임 중에는 공격하지 않아야 함")

func test_take_damage():
	# 데미지 받기 테스트
	var initial_hp = enemy.current_hp
	var damage_amount = 30
	
	enemy.take_damage(damage_amount)
	
	assert_eq(enemy.current_hp, initial_hp - damage_amount, "HP가 데미지만큼 감소해야 함")

func test_take_damage_lethal():
	# 치명적인 데미지 테스트
	enemy.current_hp = 10
	enemy.take_damage(20)
	
	assert_eq(enemy.current_hp, -10, "HP가 0 이하로 떨어져야 함")
	# queue_free()는 테스트에서 직접 확인하기 어려우므로 HP만 확인

func test_hp_bar_display():
	# HP 바 표시 테스트
	enemy.take_damage(30)
	
	assert_true(enemy.has_node("HPBarDisplay"), "데미지를 받으면 HP 바가 표시되어야 함")
	
	var hp_bar = enemy.get_node("HPBarDisplay") as ProgressBar
	assert_eq(int(hp_bar.value), enemy.current_hp, "HP 바의 값이 현재 HP와 일치해야 함")
	assert_eq(int(hp_bar.max_value), enemy.max_hp, "HP 바의 최대값이 최대 HP와 일치해야 함")

func test_chase_state_movement():
	# 추격 상태 이동 테스트
	enemy.current_state = Enemy.EnemyState.CHASE
	enemy.target = test_player
	enemy.global_position = Vector2(0, 0)
	test_player.global_position = Vector2(100, 0)
	
	# 공격 범위보다 멀리 설정하여 추격 상태 유지
	enemy.attack_range = 50.0
	
	var initial_position = enemy.global_position
	enemy._handle_chase_state(0.1)
	
	# 타겟 방향으로 이동해야 함
	var direction = (test_player.global_position - initial_position).normalized()
	var expected_velocity = direction * 50
	assert_eq(enemy.velocity, expected_velocity, "추격 상태에서 타겟 방향으로 이동해야 함")

func test_attack_range_transition():
	# 공격 범위에 따른 상태 변화 테스트
	enemy.current_state = Enemy.EnemyState.CHASE
	enemy.target = test_player
	enemy.attack_range = 100.0
	
	# 공격 범위 밖에서 추격
	enemy.global_position = Vector2(0, 0)
	test_player.global_position = Vector2(150, 0)
	enemy._handle_chase_state(0.1)
	assert_eq(enemy.current_state, Enemy.EnemyState.CHASE, "공격 범위 밖에서는 CHASE 상태 유지")
	
	# 공격 범위 안에서 공격 상태로 변경
	test_player.global_position = Vector2(50, 0)
	enemy._handle_chase_state(0.1)
	assert_eq(enemy.current_state, Enemy.EnemyState.ATTACK, "공격 범위 안에서는 ATTACK 상태로 변경")

func test_attack_range_exit():
	# 공격 범위 이탈 테스트
	enemy.current_state = Enemy.EnemyState.ATTACK
	enemy.target = test_player
	enemy.attack_range = 100.0
	
	# 공격 범위 안에서 시작
	enemy.global_position = Vector2(0, 0)
	test_player.global_position = Vector2(50, 0)
	
	# 공격 범위 밖으로 이동
	test_player.global_position = Vector2(150, 0)
	enemy._handle_attack_state(0.1)
	
	assert_eq(enemy.current_state, Enemy.EnemyState.CHASE, "공격 범위를 벗어나면 CHASE 상태로 변경되어야 함")

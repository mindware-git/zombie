extends GutTest

var player: Player
var test_enemy: Enemy

func before_each():
	# Player 씬에서 instantiate
	var player_scene = load("res://src/entity/character/player.tscn")
	player = player_scene.instantiate()
	player.name = "TestPlayer"
	add_child_autofree(player)
	
	# Enemy 생성 (테스트용)
	test_enemy = Enemy.new()
	
	# Enemy의 필수 컴포넌트 설정
	var detect_range = Area2D.new()
	detect_range.name = "DetectRange"
	test_enemy.add_child(detect_range)
	
	var raycast = RayCast2D.new()
	raycast.name = "RayCast2D"
	test_enemy.add_child(raycast)
	
	var animated_sprite = AnimatedSprite2D.new()
	animated_sprite.name = "AnimatedSprite2D"
	test_enemy.add_child(animated_sprite)
	
	test_enemy.add_to_group("enemy")
	add_child_autofree(test_enemy)


func test_player_initialization():
	# 플레이어가 올바르게 초기화되는지 테스트
	assert_eq(player.current_hp, player.max_hp, "초기 HP는 최대 HP여야 함")
	assert_eq(player.current_stamina, player.max_stamina, "초기 스테미나는 최대 스테미나여야 함")
	assert_eq(player.current_weapon, Player.WeaponType.FIST, "초기 무기는 FIST여야 함")
	assert_eq(player.attack_damage, 50, "초기 공격력은 50이어야 함")
	assert_eq(player.attack_range, 100.0, "초기 공격 범위는 100이어야 함")

func test_take_damage():
	# 데미지 받기 테스트
	var initial_hp = player.current_hp
	var damage_amount = 30
	
	player.take_damage(damage_amount)
	
	assert_eq(player.current_hp, initial_hp - damage_amount, "HP가 데미지만큼 감소해야 함")

func test_hp_bar_update():
	# HP 바 업데이트 테스트
	player.take_damage(30)
	
	var expected_percentage = float(player.current_hp) / float(player.max_hp) * 100.0
	assert_eq(player.get_node("CanvasLayer/VBoxContainer/HPBar").value, expected_percentage, "HP 바가 현재 HP 비율을 반영해야 함")

func test_stamina_bar_update():
	# 스테미나 바 업데이트 테스트
	player.current_stamina = 70
	player.update_stamina_bar()
	
	var expected_percentage = float(player.current_stamina) / float(player.max_stamina) * 100.0
	assert_eq(player.get_node("CanvasLayer/VBoxContainer/StaminaBar").value, expected_percentage, "스테미나 바가 현재 스테미나 비율을 반영해야 함")

func test_weapon_switch_to_gun():
	# 무기 전환 테스트 (FIST → GUN)
	player.update_weapon(Player.WeaponType.GUN)
	
	assert_eq(player.current_weapon, Player.WeaponType.GUN, "무기가 GUN으로 변경되어야 함")
	assert_eq(player.attack_damage, 200, "GUN 공격력은 200이어야 함")
	assert_eq(player.attack_range, 200.0, "GUN 공격 범위는 200이어야 함")
	assert_eq(player.attack_cooltime, 10.0, "GUN 쿨타임은 10이어야 함")

func test_weapon_switch_to_fist():
	# 무기 전환 테스트 (GUN → FIST)
	player.update_weapon(Player.WeaponType.GUN)
	player.update_weapon(Player.WeaponType.FIST)
	
	assert_eq(player.current_weapon, Player.WeaponType.FIST, "무기가 FIST로 변경되어야 함")
	assert_eq(player.attack_damage, 50, "FIST 공격력은 50이어야 함")
	assert_eq(player.attack_range, 50.0, "FIST 공격 범위는 50이어야 함")
	assert_eq(player.attack_cooltime, 0.5, "FIST 쿨타임은 0.5이어야 함")

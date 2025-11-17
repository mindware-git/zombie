extends GutTest

func before_each():
	SaveManager.remove_save_file()
	SaveManager.game_data = GameData.new()

func test_save_and_load():
	var test_entity = BaseEntity.new()
	test_entity.id = 123
	test_entity.amount = 45

	SaveManager.game_data.owned_entities.append(test_entity)
	SaveManager.game_data.running_time = 3600
	SaveManager.save_game()
	SaveManager.game_data = GameData.new()
	SaveManager.format_check()
	
	assert_eq(SaveManager.game_data.owned_entities.size(), 1, "엔티티가 1개 저장되어야 함")
	assert_eq(SaveManager.game_data.owned_entities[0].id, 123, "엔티티 ID가 유지되어야 함")
	assert_eq(SaveManager.game_data.owned_entities[0].amount, 45, "엔티티 수량이 유지되어야 함")
	assert_eq(SaveManager.game_data.running_time, 3600, "실행 시간이 유지되어야 함")
	assert_eq(SaveManager.game_data.format_version, 1, "포맷 버전이 유지되어야 함")

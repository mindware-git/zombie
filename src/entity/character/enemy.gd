extends BaseCharacter
class_name Enemy

enum EnemyState {
	IDLE,
	CHASE,
	ATTACK
}

var attackable = true
var in_attack_range = false
var current_state: EnemyState = EnemyState.IDLE
var player_detected = false

func _ready() -> void:
	super._ready()
	add_to_group("enemy")
	
	# DetectRange 시그널 연결
	$DetectRange.body_entered.connect(_on_detect_range_body_entered)
	$DetectRange.body_exited.connect(_on_detect_range_body_exited)

func _process(delta: float) -> void:
		match current_state:
				EnemyState.IDLE:
						_handle_idle_state(delta)
				EnemyState.CHASE:
						_handle_chase_state(delta)
				EnemyState.ATTACK:
						_handle_attack_state(delta)

func _handle_idle_state(_delta: float) -> void:
		pass

func _handle_chase_state(_delta: float) -> void:
		if target:
			# RayCast2D로 타겟 조준
			var direction = (target.global_position - global_position).normalized()
			$RayCast2D.target_position = direction * 200
			
			# 거리 출력
			var distance = global_position.distance_to(target.global_position)
			
			# 공격 범위 체크
			if distance <= attack_range:
				current_state = EnemyState.ATTACK
			else:
				velocity = direction * 50 # 속도 조정
				move_and_slide()
func _handle_attack_state(delta: float) -> void:
		if target:
			# RayCast2D로 타겟 조준
			var direction = (target.global_position - global_position).normalized()
			$RayCast2D.target_position = direction * 200
			
			var distance = global_position.distance_to(target.global_position)
			
			# 공격 범위를 벗어나면 다시 추격
			if distance > attack_range:
				current_state = EnemyState.CHASE
			else:
				# 쿨타임 감소
				attack_timer -= delta
				
				# 쿨타임이 되면 공격
				if attack_timer <= 0:
					if target.has_method("take_damage"):
						target.take_damage(20)
						attack_timer = attack_cooltime
						print("Attack! Damage: 20")

func _on_detect_range_body_entered(_body: Node2D) -> void:
		print("player detected")
		player_detected = true
		target = _body
		
		# RayCast2D를 타겟 방향으로 설정
		var direction = (target.global_position - global_position).normalized()
		$RayCast2D.target_position = direction * 200
		
		if current_state == EnemyState.IDLE:
				current_state = EnemyState.CHASE


func _on_detect_range_body_exited(_body: Node2D) -> void:
		print("player out detected")
		player_detected = false
		if current_state == EnemyState.CHASE:
				current_state = EnemyState.IDLE
				target = null

#func _on_timer_timeout() -> void:
		#attackable = true
#
func take_damage(amount: int) -> void:
	super.take_damage(amount)
	if current_hp <= 0:
		queue_free()
	show_hp_bar()

func show_hp_bar():
	# 이미 HP 바가 표시 중이면 제거
	if has_node("HPBarDisplay"):
		$HPBarDisplay.queue_free()
	
	# HP 바 생성
	var hp_bar = ProgressBar.new()
	hp_bar.name = "HPBarDisplay"
	hp_bar.position = Vector2(-25, -50) # 머리 위 위치
	hp_bar.size = Vector2(50, 8)
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	
	# 스타일 설정
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color.RED
	style_box.border_width_left = 1
	style_box.border_width_right = 1
	style_box.border_width_top = 1
	style_box.border_width_bottom = 1
	style_box.border_color = Color.BLACK
	hp_bar.add_theme_stylebox_override("fill", style_box)
	
	# Enemy에 추가
	add_child(hp_bar)
	
	# Timer를 직접 생성하고 관리
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.timeout.connect(_on_hp_bar_timer_timeout.bind(hp_bar, timer))
	add_child(timer)
	timer.start()

func _on_hp_bar_timer_timeout(hp_bar: ProgressBar, timer: Timer):
	if hp_bar and is_inside_tree():
		hp_bar.queue_free()
	if timer and is_inside_tree():
		timer.queue_free()

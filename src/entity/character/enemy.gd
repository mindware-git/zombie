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

# 어슬렁 거리기 관련 변수
var wander_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO
var is_wandering: bool = false
var wander_speed: float = 30.0 # 추격 속도보다 느리게
var wander_duration: float = 2.0 # 움직임 지속 시간
var idle_wait_time: float = 3.0 # 대기 시간

func _ready() -> void:
	super._ready()
	add_to_group("enemy")
	
	# DetectRange 시그널 연결
	$DetectRange.body_entered.connect(_on_detect_range_body_entered)
	$DetectRange.body_exited.connect(_on_detect_range_body_exited)
	
	# HP 바 초기 설정
	$HPBar.visible = false
	$HPBar.max_value = max_hp
	$HPBar.value = current_hp
	
	# 스타일 설정
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color.RED
	style_box.border_width_left = 1
	style_box.border_width_right = 1
	style_box.border_width_top = 1
	style_box.border_width_bottom = 1
	style_box.border_color = Color.BLACK
	$HPBar.add_theme_stylebox_override("fill", style_box)
	
	# 어슬렁 거리기 초기화
	start_idle_wait()

func _process(delta: float) -> void:
		match current_state:
				EnemyState.IDLE:
						_handle_idle_state(delta)
				EnemyState.CHASE:
						_handle_chase_state(delta)
				EnemyState.ATTACK:
						_handle_attack_state(delta)

func _handle_idle_state(delta: float) -> void:
	# 타이머 업데이트
	wander_timer -= delta
	
	if wander_timer <= 0:
		# 상태 전환
		if is_wandering:
			# 움직임 멈추고 대기 시작
			start_idle_wait()
		else:
			# 랜덤 방향으로 움직임 시작
			start_wandering()
	
	# 움직임 상태일 때만 이동
	if is_wandering:
		velocity = wander_direction * wander_speed
		move_and_slide()
		current_direction = wander_direction
		update_sprite_direction()
	else:
		velocity = Vector2.ZERO

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
				# 추격이 끝나면 다시 어슬렁 거리기 시작
				start_idle_wait()

#func _on_timer_timeout() -> void:
		#attackable = true
#
func take_damage(amount: int) -> void:
	super.take_damage(amount)
	if current_hp <= 0:
		queue_free()
	show_hp_bar()

func show_hp_bar():
	# HP 바가 이미 표시 중이면 값만 업데이트하고 타이머 리셋
	if $HPBar.visible:
		$HPBar.value = current_hp
	else:
		# HP 바가 숨겨져 있으면 보여주고 값 설정
		$HPBar.visible = true
		$HPBar.value = current_hp
	
	# 타이머 리셋하고 시작
	$HPBarTimer.stop()
	$HPBarTimer.start()


func _on_hp_bar_timer_timeout() -> void:
	# 타이머가 만료되면 HP 바 숨김
	$HPBar.visible = false

# 어슬렁 거리기 보조 함수들
func start_wandering():
	# 랜덤 방향 생성 (360도)
	var random_angle = randf() * 2 * PI
	wander_direction = Vector2.from_angle(random_angle)
	
	# 움직임 상태로 전환
	is_wandering = true
	wander_timer = wander_duration

func start_idle_wait():
	# 대기 상태로 전환
	is_wandering = false
	wander_timer = idle_wait_time + randf() * 2.0 # 랜덤성 추가
	
	# 속도 멈춤
	velocity = Vector2.ZERO

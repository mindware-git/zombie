extends CharacterBody2D
class_name BaseCharacter

## 시그널 정의
#signal health_changed(current_health: int, max_health: int)
#signal character_died(character: BaseCharacter)
#signal damage_dealt(target: BaseCharacter, damage: int)
#signal stun_applied(duration: float)
#signal character_healed(amount: int)

@export var max_health: int = 100
@export var movement_speed: float = 100.0
#@export var acceleration: float = 500.0
#@export var friction: float = 500.0
#@export var rotation_speed: float = 5.0

var current_health: int
#var is_alive: bool = true
#var is_stunned: bool = false
#var stun_timer: float = 0.0
#var invulnerable_timer: float = 0.0
#
## 컴포넌트 참조
#var animation_player: AnimationPlayer
#var sprite: Sprite2D
#var collision_shape: CollisionShape2D
#
## 이동 관련
#var input_direction: Vector2 = Vector2.ZERO
#var current_direction: Vector2 = Vector2.UP
#
## 초기화
func _ready():
	current_health = max_health
	#
	## 컴포넌트 참조 가져오기
	#animation_player = $AnimationPlayer
	#sprite = $Sprite2D
	#collision_shape = $CollisionShape2D
	#
	## 컴포넌트가 없으면 경고 출력
	#if not animation_player:
		#push_warning("AnimationPlayer not found in " + name)
	#if not sprite:
		#push_warning("Sprite2D not found in " + name)
	#if not collision_shape:
		#push_warning("CollisionShape2D not found in " + name)
#
## 물리 업데이트
#func _physics_process(delta):
	#if not is_alive:
		#return
	#
	## 기절 상태 업데이트
	#update_stun_state(delta)
	#
	## 무적 상태 업데이트
	#update_invulnerability(delta)
	#
	## 이동 처리 (하위 클래스에서 오버라이드 가능)
	#if not is_stunned:
		#handle_movement(delta)
	#
	## 물리 이동 적용
	#move_and_slide()
#
## 기절 상태 업데이트
#func update_stun_state(delta: float):
	#if is_stunned:
		#stun_timer -= delta
		#if stun_timer <= 0:
			#is_stunned = false
			#stun_timer = 0
			#on_stun_ended()
#
## 무적 상태 업데이트
#func update_invulnerability(delta: float):
	#if invulnerable_timer > 0:
		#invulnerable_timer -= delta
		#if invulnerable_timer <= 0:
			#invulnerable_timer = 0
			#on_invulnerability_ended()
#
## 이동 처리 (가상 함수 - 하위 클래스에서 오버라이드)
#func handle_movement(delta: float):
	## 기본 구현: 입력 방향으로 이동
	#if input_direction.length() > 0:
		#current_direction = input_direction.normalized()
		#velocity = velocity.move_toward(input_direction * movement_speed, acceleration * delta)
	#else:
		#velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	#
	## 스프라이트 방향 업데이트
	#update_sprite_direction()
#
## 스프라이트 방향 업데이트
#func update_sprite_direction():
	#if sprite and current_direction.length() > 0:
		## 8방향 스프라이트 회전 (필요시 조정)
		#var angle = current_direction.angle()
		#sprite.rotation = angle
#
## 데미지 처리
#func take_damage(amount: int, attacker: BaseCharacter = null) -> bool:
	#if not is_alive or invulnerable_timer > 0:
		#return false
	#
	## 데미지 적용
	#current_health = max(0, current_health - amount)
	#
	## 체력 변경 시그널
	#health_changed.emit(current_health, max_health)
	#
	## 데미지 효과
	#on_damage_taken(amount, attacker)
	#
	## 사망 체크
	#if current_health <= 0:
		#die()
	#else:
		## 짧은 무적 시간 부여
		#invulnerable_timer = 0.5
	#
	#return true
#
## 회복 처리
#func heal(amount: int) -> bool:
	#if not is_alive or current_health >= max_health:
		#return false
	#
	#var old_health = current_health
	#current_health = min(max_health, current_health + amount)
	#
	## 회복량
	#var actual_heal = current_health - old_health
	#
	#if actual_heal > 0:
		#character_healed.emit(actual_heal)
		#on_healed(actual_heal)
		#return true
	#
	#return false
#
## 기절 적용
#func apply_stun(duration: float):
	#if not is_alive:
		#return
	#
	#is_stunned = true
	#stun_timer = duration
	#velocity = Vector2.ZERO
	#
	#stun_applied.emit(duration)
	#on_stun_applied(duration)
#
## 사망 처리
#func die():
	#if not is_alive:
		#return
	#
	#is_alive = false
	#velocity = Vector2.ZERO
	#
	## 충돌 비활성화
	#if collision_shape:
		#collision_shape.disabled = true
	#
	#character_died.emit(self)
	#on_death()
#
## 이동 방향 설정
#func set_movement_direction(direction: Vector2):
	#input_direction = direction.normalized()
#
## 현재 체력 비율 (0.0 ~ 1.0)
#func get_health_percentage() -> float:
	#return float(current_health) / float(max_health)
#
## 무적 상태인지 확인
#func is_invulnerable() -> bool:
	#return invulnerable_timer > 0
#
## 기절 상태인지 확인
#func is_character_stunned() -> bool:
	#return is_stunned
#
## === 가상 함수 (하위 클래스에서 오버라이드) ===
#
## 데미지를 받았을 때 호출 (가상 함수)
#func on_damage_taken(amount: int, attacker: BaseCharacter):
	## 기본 구현: 피격 애니메이션 재생
	#if animation_player:
		#animation_player.play("hurt")
	#
	## 피격 효과 (깜빡임 등)
	#if sprite:
		#sprite.modulate = Color.RED
		#await get_tree().create_timer(0.1).timeout
		#sprite.modulate = Color.WHITE
#
## 회복되었을 때 호출 (가상 함수)
#func on_healed(amount: int):
	## 기본 구현: 회복 이펙트
	#if sprite:
		#sprite.modulate = Color.GREEN
		#await get_tree().create_timer(0.2).timeout
		#sprite.modulate = Color.WHITE
#
## 기절되었을 때 호출 (가상 함수)
#func on_stun_applied(duration: float):
	## 기본 구현: 기절 애니메이션
	#if animation_player and animation_player.has_animation("stun"):
		#animation_player.play("stun")
#
## 기절이 끝났을 때 호출 (가상 함수)
#func on_stun_ended():
	## 기본 구현: 대기 애니메이션
	#if animation_player and animation_player.has_animation("idle"):
		#animation_player.play("idle")
#
## 무적 시간이 끝났을 때 호출 (가상 함수)
#func on_invulnerability_ended():
	## 기본 구현: 스프라이트 투명도 복원
	#if sprite:
		#sprite.modulate.a = 1.0
#
## 사망했을 때 호출 (가상 함수)
#func on_death():
	## 기본 구현: 사망 애니메이션
	#if animation_player and animation_player.has_animation("death"):
		#animation_player.play("death")
		## 애니메이션이 끝나면 오브젝트 제거
		#await animation_player.animation_finished
		#queue_free()
	#else:
		## 애니메이션이 없으면 즉시 제거
		#queue_free()
#
## === 유틸리티 함수 ===
#
## 캐릭터 정보 출력 (디버그용)
#func print_character_info():
	#print("=== Character Info ===")
	#print("Name: ", name)
	#print("Health: ", current_health, "/", max_health)
	#print("Alive: ", is_alive)
	#print("Stunned: ", is_stunned)
	#print("Position: ", global_position)
	#print("===================")
#
## 캐릭터 리셋
#func reset_character():
	#current_health = max_health
	#is_alive = true
	#is_stunned = false
	#stun_timer = 0.0
	#invulnerable_timer = 0.0
	#velocity = Vector2.ZERO
	#input_direction = Vector2.ZERO
	#
	#if collision_shape:
		#collision_shape.disabled = false
	#
	#if sprite:
		#sprite.modulate = Color.WHITE
	#
	#health_changed.emit(current_health, max_health)

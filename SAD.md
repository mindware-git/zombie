# Software Architecture Design (SAD) — Zombie Escape (Godot)

## 1. Introduction
### 1.1 Purpose
이 문서는 모바일용 Godot 엔진 기반 게임 **"Zombie Escape"**의 소프트웨어 아키텍처 설계서(SAD)이다. 게임의 전체 구조, 컴포넌트 설계, 데이터 모델, 기술적 제약, 품질 속성 등을 정의하여 개발 과정에서 일관된 기준을 제공한다.

### 1.2 Scope
- Godot 4.x 기반 모바일(iOS/Android) 게임
- 싱글플레이, 로컬 저장 방식
- 주요 기능: 씬 전환, 좀비 AI, 전투 시스템, 퍼즐 시스템, 아이템 수집, 스토리 진행, 세이브·로드, UI, 오디오, 애니메이션

### 1.3 Definitions, Acronyms, and Abbreviations
- FSM: Finite State Machine
- Autoload: Godot의 글로벌 싱글톤 스크립트
- Resource: Godot의 데이터 기반 객체(.tres/.res)
- TileMap/Atlas: Godot 타일맵 및 아틀라스 시스템

### 1.4 References
- STORY.md
- Godot Documentation 4.x

---

## 2. Requirements Overview
### 2.1 Functional Requirements

#### Game Flow Management
- 씬 전환 시스템 (병원 → 시가지 → 평원 → 숲 → 동굴 → 야영지)
- 튜토리얼 시스템
- 자동 저장 시스템 (특정 이벤트 트리거 기반)
- 세이브/로드 시스템 (세이브 포인트)

#### Zombie Combat System
- 좀비 AI 및 행동 패턴 (좁은 시야, 인지 시 빠른 돌진)
- 전투 시스템 (근접/원거리 무기)
- 좀비 보스 전투 시스템
- 자동 사냥 기능 (피로도 감소)

#### Puzzle System
- 발전기 작동 퍼즐
- 자물쇠 및 퀴즈 퍼즐 (코인/빠칭코 힌트 시스템)
- 점진적 난이도 증가

#### Player Progression
- 체력/스테미나 시스템
- 스킬 시스템 (액티브/패시브 스킬 트리)
- 무기 장착 및 아이템 관리
- 경험치 및 레벨 업 시스템

#### Story & Quest System
- Act 1-3 스토리 진행 관리
- 퀘스트 시스템 (생존자 기지 찾기, 백신 찾기 등)
- 대화 및 독백 시스템

#### UI Layout System
- 퀘스트 진행사항 UI (왼쪽 상단 배치)
- 아이템/설정 메뉴 UI (오른쪽 상단 배치)
- 퀘스트 상세 정보 팝업 시스템
- 인벤토리 및 설정 팝업 시스템

#### Exploration & Interaction
- 시야 시스템 (어두운 곳에서 라이트)
- 아이템 수집 및 상호작용
- 맵 특성 및 숨겨진 요소

### 2.2 Non-Functional Requirements
- 30–60 FPS 모바일 퍼포먼스
- 낮은 메모리 사용량
- 빠른 로딩 및 부드러운 씬 전환
- 확장성: 맵/좀비/아이템/퍼즐 추가 용이
- 유지보수성 높은 구조(컴포넌트 분리)

---

## 3. System Overview
### 3.1 System Context Diagram
- 외부 시스템: 모바일 OS(터치 입력, 파일 저장소), 광고 SDK(선택), 분석/크래시 리포트

### 3.2 Major System Components
- GameManager (Autoload)
- SaveManager (Autoload)
- AudioManager (Autoload)
- PoolManager (Autoload)
- SceneController
- ZombieManager
- CombatManager
- PuzzleManager
- PlayerController
- InventoryManager
- SkillManager
- QuestManager
- UIManager
- AutoSaveTrigger
- QuestUIComponent
- MenuUIComponent
- Zombie (FSM)
- Weapon System
- Item System

---

## 4. Architectural Design
### 4.1 Architectural Style
- 계층형 아키텍처 + Godot 씬 기반 컴포넌트 아키텍처
  - Presentation(UI)
  - Scene Logic(Hospital, City, Forest, Cave, Camp)
  - Core Systems (Managers)
  - Data Resources(Weapons, Items, Zombies)

### 4.2 High-Level Architecture Diagram
```
Input (Touch/Controls)
   ↓
UI Layer (HUD, Inventory, Puzzle UI, Dialogue)
   ├── QuestUI (Top-Left: Quest Progress)
   ├── MenuUI (Top-Right: Items/Settings)
   └── SaveIndicator (Auto-save Feedback)
   ↓
Scene Controller (Hospital, City, Forest, Cave, Camp)
   ↓
Managers (GameManager, ZombieManager, CombatManager, PuzzleManager, SaveManager, AutoSaveTrigger)
   ↓
Resource/Assets (Weapons, Items, Sounds, Sprites)
```

### 4.3 Component Diagrams
- GameManager: 씬 전환, 게임 상태 관리
- SaveManager: .tres 리소스 기반 저장/로드, 자동 저장 처리
- AutoSaveTrigger: 이벤트 기반 자동 저장 트리거 관리
- ZombieManager: 좀비 스폰, AI 초기화, 행동 관리
- CombatManager: 전투 로직, 데미지 계산, 스킬 처리
- PuzzleManager: 퍼즐 상태, 진행도, 보상 관리
- PlayerController: 플레이어 이동, 액션, 상태 관리
- InventoryManager: 아이템 저장, 장착, 사용, UI 연동
- SkillManager: 스킬 트리, 스킬 발동, 효과 관리
- QuestManager: 퀘스트 관리, UI 연동
- QuestUIComponent: 퀘스트 진행사항 표시 (왼쪽 상단)
- MenuUIComponent: 아이템/설정 메뉴 (오른쪽 상단)

---

## 5. Component Design
### 5.1 Zombie Component
**Purpose**: 좀비 개체의 AI, 행동, 상호작용 처리

**Core Responsibilities**:
- 좀비 생성 및 스폰 관리
- AI 행동 패턴 (순찰, 인지, 추격, 공격)
- 시야 시스템 및 플레이어 인지
- 공격 패턴 및 데미지 처리
- 상태 변화 관리 (FSM)

**Key Attributes**:
- `zombie_id`: 고유 식별자
- `zombie_type`: 좀비 종류 (일반, 강아지, 보스)
- `health`: 현재 체력
- `max_health`: 최대 체력
- `damage`: 공격력
- `detection_range`: 인지 범위
- `movement_speed`: 이동 속도
- `state`: 현재 상태 (idle, patrol, chase, attack, dead)

**Key Methods**:
- `spawn(position, type)`: 좀비 생성
- `update_ai(delta_time)`: AI 업데이트
- `detect_player()`: 플레이어 인지
- `chase_player(target)`: 플레이어 추격
- `attack_target(target)`: 대상 공격
- `take_damage(amount)`: 데미지 처리
- `die()`: 사망 처리

**Signals**:
- `zombie_spawned`: 좀비 생성 시
- `player_detected`: 플레이어 인지 시
- `attack_landed`: 공격命中 시
- `zombie_died`: 좀비 사망 시

### 5.2 PlayerController
**Purpose**: 플레이어 캐릭터의 이동, 액션, 상태 관리

**Core Responsibilities**:
- 터치 입력 기반 이동 제어
- 무기 장착 및 사용
- 아이템 상호작용
- 체력/스테미나 관리
- 애니메이션 제어

**Key Attributes**:
- `health`: 현재 체력
- `max_health`: 최대 체력
- `stamina`: 현재 스테미나
- `max_stamina`: 최대 스테미나
- `current_weapon`: 현재 장착 무기
- `movement_speed`: 이동 속도
- `is_light_on`: 라이트 활성화 여부

**Key Methods**:
- `move_to_position(position)`: 특정 위치로 이동
- `use_weapon()`: 무기 사용
- `interact_with_object(object)`: 오브젝트 상호작용
- `use_item(item)`: 아이템 사용
- `toggle_light()`: 라이트 전환
- `take_damage(amount)`: 데미지 처리

### 5.3 CombatManager
**Purpose**: 전투 시스템 전체 관리

**Core Responsibilities**:
- 전투 로직 처리
- 데미지 계산
- 스킬 발동 및 효과 관리
- 자동 사냥 기능
- 전투 결과 처리

**Key Methods**:
- `calculate_damage(attacker, target, weapon)`: 데미지 계산
- `process_skill(skill, user, target)`: 스킬 처리
- `start_auto_combat()`: 자동 전투 시작
- `end_combat(result)`: 전투 종료 처리

### 5.4 PuzzleManager
**Purpose**: 퍼즐 시스템 관리

**Core Responsibilities**:
- 퍼즐 상태 관리
- 퍼즐 진행도 추적
- 힌트 시스템
- 퍼즐 완료 보상 처리

**Key Methods**:
- `init_puzzle(puzzle_id)`: 퍼즐 초기화
- `update_puzzle_state(action)`: 퍼즐 상태 업데이트
- `check_puzzle_completion()`: 퍼즐 완료 확인
- `provide_hint(hint_id)`: 힌트 제공

### 5.5 InventoryManager
**Purpose**: 아이템 및 인벤토리 관리

**Core Responsibilities**:
- 아이템 저장 및 관리
- 무기 장착 시스템
- 아이템 사용 및 효과
- 인벤토리 UI 연동

**Key Methods**:
- `add_item(item_resource, quantity)`: 아이템 추가
- `remove_item(item_id, quantity)`: 아이템 제거
- `equip_weapon(weapon_resource)`: 무기 장착
- `use_consumable(item_id)`: 소모품 사용

### 5.6 SkillManager
**Purpose**: 스킬 시스템 관리

**Core Responsibilities**:
- 스킬 트리 관리
- 액티브/패시브 스킬 처리
- 스킬 레벨 업
- 스킬 효과 적용

**Key Methods**:
- `unlock_skill(skill_id)`: 스킬 해금
- `upgrade_skill(skill_id)`: 스킬 레벨 업
- `activate_skill(skill_id, target)`: 스킬 발동
- `apply_passive_effects()`: 패시브 효과 적용

### 5.7 AutoSaveTrigger
**Purpose**: 이벤트 기반 자동 저장 트리거 관리

**Core Responsibilities**:
- 특정 이벤트 감지 및 자동 저장 실행
- 저장 상태 UI 피드백 제공
- 저장 트리거 이력 관리

**Key Attributes**:
- `trigger_events`: 자동 저장 트리거 이벤트 목록
- `save_cooldown`: 저장 쿨다운 시간
- `is_saving`: 현재 저장 중 여부
- `last_save_time`: 마지막 저장 시간

**Key Methods**:
- `register_trigger_event(event_id, condition)`: 트리거 이벤트 등록
- `check_and_trigger_save(event_data)`: 이벤트 체크 및 자동 저장 실행
- `show_save_indicator()`: 저장 상태 UI 표시
- `get_save_history()`: 저장 이력 조회

**Auto-Save Trigger Events**:
- `quest_completed`: 퀘스트 완료 시
- `boss_defeated`: 보스 처치 시
- `scene_changed`: 맵 이동 시
- `important_item_acquired`: 중요 아이템 획득 시
- `puzzle_completed`: 퍼즐 완료 시

**Signals**:
- `auto_save_triggered`: 자동 저장 트리거 발생 시
- `save_completed`: 저장 완료 시
- `save_failed`: 저장 실패 시

### 5.8 QuestUIComponent
**Purpose**: 퀘스트 진행사항 UI 관리 (왼쪽 상단 배치)

**Core Responsibilities**:
- 현재 활성 퀘스트 목록 표시
- 퀘스트 상태별 시각적 표현
- 클릭 시 상세 정보 팝업 표시
- 퀘스트 완료/업데이트 애니메이션

**Key Attributes**:
- `quest_list`: 표시할 퀘스트 목록
- `max_display_count`: 최대 표시 퀘스트 수
- `ui_position`: UI 위치 (왼쪽 상단 고정)
- `is_expanded`: 상세 정보 펼침 여부

**Key Methods**:
- `update_quest_list(quests)`: 퀘스트 목록 업데이트
- `show_quest_details(quest_id)`: 퀘스트 상세 정보 팝업 표시
- `highlight_completed_quest(quest_id)`: 완료된 퀘스트 강조 표시
- `set_quest_status_indicator(quest_id, status)`: 퀘스트 상태 표시기 설정

**Quest Status Indicators**:
- `active`: 진행중 (파란색 아이콘)
- `completed`: 완료됨 (초록색 체크)
- `failed`: 실패함 (빨간색 X)

**UI Elements**:
- 퀘스트 아이콘 및 제목
- 진행도 바 (선택사항)
- 상태 표시기
- 클릭 가능한 영역

### 5.9 MenuUIComponent
**Purpose**: 아이템/설정 메뉴 UI 관리 (오른쪽 상단 배치)

**Core Responsibilities**:
- 아이템 인벤토리 팝업 관리
- 설정 메뉴 팝업 관리
- 메뉴 아이콘 표시 및 상호작용
- 팝업 창 제어 및 애니메이션

**Key Attributes**:
- `menu_buttons`: 메뉴 버튼 목록
- `is_inventory_open`: 인벤토리 팝업 열림 여부
- `is_settings_open`: 설정 팝업 열림 여부
- `ui_position`: UI 위치 (오른쪽 상단 고정)

**Key Methods**:
- `show_inventory_popup()`: 인벤토리 팝업 표시
- `show_settings_popup()`: 설정 팝업 표시
- `close_all_popups()`: 모든 팝업 닫기
- `update_menu_icons()`: 메뉴 아이콘 상태 업데이트

**Menu Buttons**:
- `inventory`: 아이템 인벤토리 (가방 아이콘)
- `settings`: 게임 설정 (톱니바퀴 아이콘)
- `save`: 수동 저장 (디스크 아이콘 - 선택사항)

**Settings Options**:
- 사운드 볼륨 (BGM/효과음)
- 그래픽 품질
- 컨트롤 설정
- 언어 설정
- 튜토리얼 재생

**Inventory Features**:
- 아이템 그리드 뷰
- 아이템 상세 정보
- 아이템 정렬 필터
- 무기 장착/해제

---

## 6. Data Design
### 6.1 Resource Classes

#### GameDataResource.gd (메인 저장 데이터)
```gdscript
extends Resource
class_name GameDataResource

const LATEST_FORMAT_VERSION = 1
@export var format_version: int = LATEST_FORMAT_VERSION

# 플레이어 데이터
@export var player_level: int = 1
@export var player_experience: int = 0
@export var player_health: int = 100
@export var player_max_health: int = 100
@export var player_stamina: int = 100
@export var player_max_stamina: int = 100
@export var player_position: Vector2 = Vector2.ZERO
@export var current_scene: String = "hospital_room"

# 인벤토리 데이터
@export var inventory_items: Array[InventorySlot] = []

# 스킬 데이터
@export var player_skills: Array[SkillProgress] = []

# 퀘스트 데이터
@export var current_act: int = 1
@export var completed_quests: Array[String] = []
@export var active_quests: Array[String] = []

# 월드 상태
@export var generator_fixed: bool = false
@export var doors_unlocked: Array[String] = []
@export var zombies_defeated: Dictionary = {}

# 자동 저장 이력
@export var auto_save_history: Array[AutoSaveHistoryEntry] = []

# UI 설정
@export var ui_settings: UISettingsResource

@export var timestamp: String = ""
```

#### InventorySlot.gd (인벤토리 슬롯)
```gdscript
extends Resource
class_name InventorySlot

@export var item_id: String = ""
@export var quantity: int = 0
```

#### SkillProgress.gd (스킬 진행상태)
```gdscript
extends Resource
class_name SkillProgress

@export var skill_id: String = ""
@export var level: int = 1
```

#### AutoSaveHistoryEntry.gd (자동 저장 이력)
```gdscript
extends Resource
class_name AutoSaveHistoryEntry

@export var timestamp: String = ""
@export var trigger_event: String = ""
@export var trigger_data: Dictionary = {}
@export var scene: String = ""
```

#### UISettingsResource.gd (UI 설정)
```gdscript
extends Resource
class_name UISettingsResource

@export var quest_ui_position: Vector2 = Vector2(50, 50)
@export var menu_ui_position: Vector2 = Vector2(-50, 50)
@export var quest_display_count: int = 3
@export var show_quest_progress_bars: bool = true
```

#### WeaponResource.gd (무기 데이터)
```gdscript
extends Resource
class_name WeaponResource

@export var id: String = ""
@export var name: String = ""
@export var type: String = ""  # melee, ranged
@export var damage: int = 0
@export var range: float = 0.0
@export var fire_rate: float = 1.0
@export var ammo_type: String = ""
@export var durability: int = 100
@export var icon_path: String = ""
```

#### ZombieResource.gd (좀비 데이터)
```gdscript
extends Resource
class_name ZombieResource

@export var id: String = ""
@export var name: String = ""
@export var health: int = 100
@export var damage: int = 10
@export var speed: float = 100.0
@export var detection_range: float = 200.0
@export var ai_pattern: String = "patrol"
@export var rewards: Dictionary = {}
@export var sprite_path: String = ""
```

#### ItemResource.gd (아이템 데이터)
```gdscript
extends Resource
class_name ItemResource

@export var id: String = ""
@export var name: String = ""
@export var type: String = ""  # weapon, consumable, material
@export var effect: String = ""
@export var value: int = 0
@export var stackable: bool = true
@export var consumable: bool = false
@export var icon_path: String = ""
@export var description: String = ""
```

#### SkillResource.gd (스킬 데이터)
```gdscript
extends Resource
class_name SkillResource

@export var id: String = ""
@export var name: String = ""
@export var type: String = ""  # active, passive
@export var description: String = ""
@export var max_level: int = 5
@export var effects: Array[String] = []
@export var requirements: Dictionary = {}
@export var icon_path: String = ""
```

#### AutoSaveTriggerResource.gd (자동 저장 트리거)
```gdscript
extends Resource
class_name AutoSaveTriggerResource

@export var event_id: String = ""
@export var condition: String = ""
@export var cooldown_seconds: int = 30
@export var show_save_indicator: bool = true
@export var save_priority: String = "high"  # high, medium, low
```

#### QuestUIResource.gd (퀘스트 UI 데이터)
```gdscript
extends Resource
class_name QuestUIResource

@export var quest_id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var status: String = "active"  # active, completed, failed
@export var progress_percentage: int = 0
@export var objectives: Array[QuestObjective] = []
@export var icon_path: String = ""
@export var reward: Dictionary = {}
```

#### QuestObjective.gd (퀘스트 목표)
```gdscript
extends Resource
class_name QuestObjective

@export var id: String = ""
@export var description: String = ""
@export var completed: bool = false
```

### 6.2 Data Flow

#### Save/Load System (.tres 기반)
- **Save Flow**: 
  - AutoSaveTrigger → SaveManager.save_game() → ResourceSaver.save("user://save_data.tres", game_data)
  - SaveManager.show_save_indicator() → SaveIndicator UI 표시
- **Load Flow**: 
  - SaveManager.load_game() → ResourceLoader.load("user://save_data.tres") → GameDataResource
  - SaveManager.apply_loaded_data() → 각 매니저에 데이터 적용

#### Game Logic Flow
- PlayerController → CombatManager → Zombie (데미지 처리)
- ZombieManager → Zombie (AI 업데이트)
- PuzzleManager → UI (퍼즐 인터페이스)
- InventoryManager → PlayerController (아이템 효과 적용)
- SkillManager → PlayerController (스킬 효과 적용)

#### UI Update Flow
- QuestManager → QuestUIComponent (퀘스트 UI 업데이트)
- InventoryManager → MenuUIComponent (인벤토리 UI 연동)
- AutoSaveTrigger → SaveIndicator (저장 상태 피드백)

#### Resource Loading Flow
- ResourceLoader.load() → WeaponResource/ZombieResource/ItemResource 등
- 각 매니저 → 리소스 데이터 참조 및 적용

### 6.3 UI Layout Resource Classes

#### UILayoutResource.gd (UI 레이아웃 설정)
```gdscript
extends Resource
class_name UILayoutResource

@export var quest_ui_config: QuestUIConfig
@export var menu_ui_config: MenuUIConfig
@export var save_indicator_config: SaveIndicatorConfig
```

#### QuestUIConfig.gd (퀘스트 UI 설정)
```gdscript
extends Resource
class_name QuestUIConfig

@export var position: String = "top_left"
@export var anchor: Vector2 = Vector2(0.05, 0.05)
@export var size: Vector2 = Vector2(300, 120)
@export var max_quests: int = 3
@export var show_progress: bool = true
@export var clickable: bool = true
@export var quest_spacing: float = 10.0
@export var icon_size: Vector2 = Vector2(32, 32)
```

#### MenuUIConfig.gd (메뉴 UI 설정)
```gdscript
extends Resource
class_name MenuUIConfig

@export var position: String = "top_right"
@export var anchor: Vector2 = Vector2(0.95, 0.05)
@export var button_size: Vector2 = Vector2(60, 60)
@export var buttons: Array[String] = ["inventory", "settings", "save"]
@export var spacing: float = 10.0
@export var popup_scale: float = 1.0
```

#### SaveIndicatorConfig.gd (저장 표시기 설정)
```gdscript
extends Resource
class_name SaveIndicatorConfig

@export var position: String = "top_center"
@export var anchor: Vector2 = Vector2(0.5, 0.1)
@export var animation_duration: float = 2.0
@export var fade_duration: float = 0.5
@export var icon_path: String = "res://assets/ui/save_icon.png"
@export var show_text: bool = true
@export var save_text: String = "게임이 저장되었습니다"
```

#### SaveManager Integration
```gdscript
# SaveManager.gd의 핵심 메서드 예시
func save_game() -> bool:
    var game_data = GameDataResource.new()
    
    # 현재 게임 상태를 game_data에 저장
    game_data.player_level = player_controller.level
    game_data.player_health = player_controller.health
    game_data.inventory_items = inventory_manager.get_inventory_slots()
    game_data.player_skills = skill_manager.get_skill_progress()
    # ... 기타 데이터 저장
    
    # .tres 파일로 저장
    var save_path = "user://save_data.tres"
    var result = ResourceSaver.save(game_data, save_path)
    
    if result == OK:
        auto_save_trigger.show_save_indicator()
        return true
    else:
        push_error("Failed to save game: " + str(result))
        return false

func load_game() -> bool:
    var save_path = "user://save_data.tres"
    
    if not FileAccess.file_exists(save_path):
        return false
    
    var game_data = ResourceLoader.load(save_path)
    if not game_data is GameDataResource:
        push_error("Invalid save file format")
        return false
    
    # 저장된 데이터를 각 매니저에 적용
    player_controller.load_data(game_data)
    inventory_manager.load_data(game_data)
    skill_manager.load_data(game_data)
    # ... 기타 매니저에 데이터 적용
    
    return true
```

---

## 7. Deployment View
### 7.1 Target Platforms
- iOS / Android
- Godot Export Template 사용

### 7.2 Infrastructure Requirements
- Android SDK
- Xcode(iOS)
- Resource 관리(스프라이트 아틀라스, 오디오 압축)

---

## 8. Quality Attributes
- **Performance**: 오브젝트 풀링, 좀비 AI 최적화, 저해상도 타일맵, draw-call 최소화
- **Scalability**: 신규 맵/좀비/아이템/퍼즐 리소스만 추가하면 확장 가능
- **Maintainability**: 씬/스크립트 모듈화, Autoload 최소화, FSM 기반 AI
- **Reliability**: 안정적 저장/로드 구조, 예외 처리 강화

---

## 9. Risks and Technical Debt
- 좀비 AI 복잡성 및 성능 문제
- 모바일 메모리 한계 (맵 로딩 최적화 필요)
- FSM 상태 전환 복잡성 증가 가능성
- 퍼즐 시스템의 확장성 관리
- 멀티터치 입력 처리의 복잡성

---

## 10. Appendix
- 주요 시그널 목록
- Godot Best Practices
- 좀비 AI 상태 머신 다이어그램
- 퍼즐 시스템 흐름도
- 향후 온라인 멀티플레이어 확장 고려 사항

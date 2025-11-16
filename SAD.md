# Software Architecture Design (SAD)

## 1. Introduction
### 1.1 Purpose
Describe the purpose of this document and the system to be built.

### 1.2 Scope
Outline the scope of the system, including high-level system goals.

### 1.3 Definitions, Acronyms, and Abbreviations
List important terms and their definitions.

### 1.4 References
Provide links or references to relevant documents such as SRS, design docs, etc.

---

## 2. Requirements Overview
### 2.1 Functional Requirements

#### Game Flow Management
- **Scene Transition System**: Enable seamless switching between shop scene and kitchen scene
- **Tutorial System**: Provide basic gameplay instructions for first-time players
- **Save/Load System**: Allow players to save and resume game progress

#### Shop Scene Features
- **Customer Management**: Handle 4 available seats with customers arriving every 10 seconds
- **Order Display System**: Show desired sushi orders above customers' heads
- **Serving System**: Enable drag-and-drop serving of completed sushi to customers
- **Seat Management**: Track available seats and assign customers to empty seats

#### Kitchen Scene Features
- **Dual-Hand Control System**: Support simultaneous left hand (rice scooping) and right hand (ingredient selection, wasabi) operations
- **Cooking Mini-Game**: Implement rice amount control, ingredient selection, and decoration mechanics
- **Slot System**: Store completed sushi in slots with visibility in both scenes

#### Game Progression
- **Level System**: Track player progression and unlock new content
- **Money Management**: Monitor earnings toward 10 million won goal
- **Item/Upgrade System**: Provide upgrades for cooking speed, serving speed, and other abilities

#### Customer Interaction
- **Patience System**: Implement customer patience timer with visual dissatisfaction indicators
- **Customer Departure**: Handle customers leaving when patience runs out
- **Satisfaction Tracking**: Monitor customer satisfaction based on service quality

#### Recipe and Content
- **Recipe System**: Manage various sushi recipes and ingredients
- **Ingredient Management**: Track available ingredients and consumables
- **Progressive Content**: Unlock new recipes and ingredients as player advances

### 2.2 Non-Functional Requirements
Describe performance, scalability, security, maintainability, etc.

---

## 3. System Overview
### 3.1 System Context Diagram
Provide a high-level view of how the system interacts with external entities.

### 3.2 Major System Components
Brief description of the core components.

---

## 4. Architectural Design
### 4.1 Architectural Style
Describe the chosen architecture style (e.g., layered, microservices).

### 4.2 High-Level Architecture Diagram
Provide a diagram illustrating overall system architecture.

### 4.3 Component Diagrams
Detail the main components and how they interact.

---

## 5. Component Design
### 5.1 Customer Component

**Purpose**: The Customer component manages individual customer entities, their behavior, and interactions within the sushi shop environment. This component is responsible for simulating realistic customer behavior including ordering, waiting, and satisfaction management.

**Core Responsibilities**:
- **Customer Lifecycle Management**: Handle customer spawning, seating, and departure
- **Order Management**: Generate and display customer sushi orders
- **Patience System**: Manage customer patience timers and satisfaction levels
- **State Machine Control**: Control customer states (waiting, ordering, eating, satisfied, dissatisfied, leaving)
- **Visual Feedback**: Display order bubbles and satisfaction indicators

**Key Attributes**:
- `customer_id`: Unique identifier for each customer
- `order_type`: Specific sushi type requested by the customer
- `patience_level`: Current patience remaining (0-100)
- `satisfaction_score`: Customer satisfaction based on service quality
- `seat_assignment`: Currently assigned seat number
- `arrival_time`: Timestamp when customer entered the shop
- `order_status`: Current state of customer's order (pending, served, completed)

**Key Methods**:
- `spawn_customer()`: Create new customer instance
- `assign_seat(seat_number)`: Assign customer to specific seat
- `generate_order()`: Randomly select sushi order
- `update_patience(delta_time)`: Decrease patience over time
- `serve_sushi(sushi_type)`: Handle sushi serving and validation
- `calculate_satisfaction()`: Update satisfaction based on service speed and accuracy
- `trigger_departure()`: Handle customer leaving process

**Interactions**:
- **Seat Manager**: Request and manage seat assignments
- **Order Display System**: Update visual order indicators
- **Serving Controller**: Validate received sushi orders
- **Economy Manager**: Process payments and tips
- **Patience System Controller**: Synchronize patience timers

**Signals/Events**:
- `customer_arrived`: Fired when new customer enters
- `order_placed`: Triggered when customer places order
- `patience_warning`: Emitted when patience is running low
- `satisfaction_updated`: Fired when satisfaction level changes
- `customer_departed`: Triggered when customer leaves

**Performance Considerations**:
- Efficient state management for multiple simultaneous customers
- Optimized patience timer updates to prevent performance degradation
- Memory pooling for customer instances to reduce garbage collection

### 5.2 Component 2
Describe functionality, interactions, and responsibilities.

(Repeat for additional components)

---

## 6. Data Design
### 6.1 Database Schema
Include schema or ER diagrams.

### 6.2 Data Flow
Provide data flow diagrams if necessary.

---

## 7. Deployment View
### 7.1 Deployment Diagram
Detail how the system will be deployed across various environments.

### 7.2 Infrastructure Requirements
Specify requirements for servers, cloud services, etc.

---

## 8. Quality Attributes
Describe how the architecture meets quality goals like performance, reliability, and security.

---

## 9. Risks and Technical Debt
Identify architectural risks and areas of technical debt.

---

## 10. Appendix
Include supporting information such as design decisions or meeting notes.

# Software Architecture Design (SAD) — Zombie Escape (Godot)

## 1. Introduction
### 1.1 Purpose
이 문서는 모바일용 Godot 엔진 기반 게임 **"Zombie Escape"**의 소프트웨어 아키텍처 설계서(SAD)이다. 게임의 전체 구조, 컴포넌트 설계, 데이터 모델, 기술적 제약, 품질 속성 등을 정의하여 개발 과정에서 일관된 기준을 제공한다.

### 1.2 Scope
- Godot 4.x 기반 모바일(iOS/Android) 게임
- 싱글플레이, 로컬 저장 방식
- 주요 기능: 씬 전환, 고객/좀비 AI, 주방(요리) 시스템, 상점/식당 운영, 진행도/레벨 시스템, 세이브·로드, UI, 오디오, 애니메이션

### 1.3 Definitions, Acronyms, Abbreviations
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
- 씬 전환 시스템 (메인 메뉴 → 상점 → 주방)
- 튜토리얼 시스템
- 세이브/로드 시스템

#### Shop Scene Features
- 고객 4석 관리
- 고객 스폰/퇴장
- 주문 표시 UI
- 드래그 앤 드롭 서빙 시스템

#### Kitchen Scene Features
- 듀얼핸드 입력(멀티터치)
- 요리 미니게임: 쌀 조절/재료 선택/데코레이션
- 슬롯 시스템(완성 요리 저장)

#### Game Progression
- 레벨 시스템
- 돈/업그레이드 시스템
- 목표: 1000만 원 달성

#### Customer Interaction
- 인내도(패이션스) 시스템
- 불만/퇴장 처리
- 만족도 기반 보상

#### Recipe & Content
- 레시피/재료 관리
- 진척도 기반 레시피 해금

### 2.2 Non-Functional Requirements
- 30–60 FPS 모바일 퍼포먼스
- 낮은 메모리 사용량
- 빠른 로딩 및 부드러운 씬 전환
- 확장성: 레시피/스테이지/고객 추가 용이
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
- ShopController
- KitchenController
- CustomerManager
- Customer(FSM)
- SeatManager
- Cooking System (RiceControl / IngredientSelect / Decoration)
- SlotInventory
- EconomyManager
- UI/HUD Layer

---

## 4. Architectural Design
### 4.1 Architectural Style
- 계층형 아키텍처 + Godot 씬 기반 컴포넌트 아키텍처
  - Presentation(UI)
  - Scene Logic(Shop/Kitchen)
  - Core Systems (Managers)
  - Data Resources(Recipes, Items)

### 4.2 High-Level Architecture Diagram
```
Input (Touch)
   ↓
UI Layer (HUD, Popups)
   ↓
Scene Controller (Shop/Kitchen)
   ↓
Managers (GameManager, CustomerManager, SlotInventory, Economy)
   ↓
Resource/Assets (Recipes, Sounds, Sprites)
```

### 4.3 Component Diagrams
- GameManager: 씬 전환, 게임 상태 관리
- SaveManager: JSON 기반 저장/로드
- CustomerManager: 고객 스폰, 좌석 관리, FSM 초기화
- CookingController: 미니게임 단계 관리
- SlotInventory: 슬롯 저장 및 UI 연결
- EconomyManager: 수익/업그레이드/팁 계산

---

## 5. Component Design
### 5.1 Customer Component
**Purpose**: 고객 개별 행동, 주문, 인내도, 만족도 처리

**Core Responsibilities**:
- 고객 생성, 좌석 배정
- 주문 생성 및 표시
- 인내도 감소, 경고, 퇴장 처리
- 서빙 처리 및 만족도 계산
- FSM 상태 변화 관리

**Key Attributes**:
- `customer_id`
- `order_type`
- `patience_max`
- `patience_current`
- `satisfaction_score`
- `seat_index`
- `arrival_time`

**Key Methods**:
- `spawn(position)`
- `assign_seat(index)`
- `generate_order()`
- `update_patience(delta)`
- `serve_sushi(resource)`
- `calculate_satisfaction()`
- `depart()`

**Signals**:
- `customer_arrived`
- `order_placed`
- `patience_warning`
- `customer_departed`

### 5.2 SeatManager
- 빈 좌석 검색
- 고객-좌석 매핑
- 좌석 위치 정보 제공
- API:
  - `get_free_seat()`
  - `release_seat(index)`
  - `get_seat_position(index)`

### 5.3 Cooking System
- RiceControl.tscn: 쌀 양 조절
- IngredientSelect.tscn: 재료 선택
- Decoration.tscn: 데코레이션
- CookingController: 다음 단계로 이동, 결과물을 SlotInventory로 전달

### 5.4 SlotInventory
- 최대 N개 슬롯 보관
- 각 슬롯에는 SushiResource 저장
- UI에 표시하여 ShopScene과 공유

### 5.5 EconomyManager
- 돈 수익 계산
- 만족도 기반 팁
- 업그레이드 비용 및 효과 처리

### 5.6 UI Layer
- HUDController: 상태 표시
- TutorialManager: 단계별 안내
- PopupManager: 공통 팝업 처리

### 5.7 AudioManager
- BGM/SE 관리
- crossfade 지원

---

## 6. Data Design
### 6.1 Resource Formats
- RecipeResource (.tres):
```
{id, name, ingredients:[{id, qty}], difficulty, sell_price}
```

- Save Data JSON:
```
{
  "player": {"level":1, "money":1000},
  "inventory": [...],
  "world_state": {...},
  "timestamp": "YYYY-MM-DD HH:MM"
}
```

### 6.2 Data Flow
- SceneController → SlotInventory → ShopScene
- CustomerManager → Customer → UI OrderBubble
- CookingController → SlotInventory → EconomyManager

---

## 7. Deployment View
### 7.1 Target Platforms
- iOS / Android
- Godot Export Template 사용

### 7.2 Infrastructure Requirements
- Android SDK
- Xcode(iOS)
- Resource 관리(스프라이트 아틀라스 등)

---

## 8. Quality Attributes
- **Performance**: 오브젝트 풀, 저해상도 타일맵, draw-call 최소화
- **Scalability**: 신규 레시피/고객/스테이지 리소스만 추가하면 확장 가능
- **Maintainability**: 씬/스크립트 모듈화, Autoload 최소화
- **Reliability**: 안정적 저장/로드 구조

---

## 9. Risks and Technical Debt
- 멀티터치 듀얼핸드 복잡성
- 모바일 메모리 한계
- FSM 복잡성 증가 가능성
- 미리로드/스트리밍 최적화 필요

---

## 10. Appendix
- 주요 시그널 목록
- Godot Best Practices
- 향후 온라인 확장 고려 사항
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

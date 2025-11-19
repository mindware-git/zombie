extends Resource
class_name GameData

const LATEST_FORMAT_VERSION = 1
@export var format_version: int = LATEST_FORMAT_VERSION
@export var owned_entities: Array[BaseEntity] = []
@export var running_time: int = 0

# Generator
@export var generator_powered: bool = false

# Player
@export var max_hp: int = 100
@export var current_hp: int = 100
@export var max_stamina: int = 100
@export var current_stamina: int = 100
@export var position: Vector2 = Vector2(0, 0)

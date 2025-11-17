extends Resource
class_name GameData

const LATEST_FORMAT_VERSION = 1
@export var format_version: int = LATEST_FORMAT_VERSION
@export var owned_entities: Array[BaseEntity] = []
@export var running_time: int = 0

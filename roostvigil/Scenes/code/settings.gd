extends Node

const PATH := "user://settings.cfg"

var master_volume: float = 1.0


func _ready() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) == OK:
		master_volume = cfg.get_value("audio", "master", 1.0)
	_apply()


func set_master_volume(value: float) -> void:
	master_volume = value
	_apply()


func _apply() -> void:
	var idx := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(idx, linear_to_db(master_volume))
	AudioServer.set_bus_mute(idx, master_volume <= 0.001)


func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", master_volume)
	cfg.save(PATH)

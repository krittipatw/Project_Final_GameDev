@tool
extends EditorPlugin

const AUTOLOAD_NAME := "DayCycle"
const AUTOLOAD_PATH := "res://addons/time_day_night/DayCycle.gd"


func _enter_tree() -> void:
	if not ProjectSettings.has_setting(
		"autoload/" + AUTOLOAD_NAME
	):
		add_autoload_singleton(
			AUTOLOAD_NAME,
			AUTOLOAD_PATH
		)


func _exit_tree() -> void:
	if ProjectSettings.has_setting(
		"autoload/" + AUTOLOAD_NAME
	):
		remove_autoload_singleton(AUTOLOAD_NAME)

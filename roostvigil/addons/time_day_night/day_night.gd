extends CanvasModulate

@onready var shadows: Polygon2D = $"../Shadows"

@export_group("Time Settings")
## The hour when sunrise occurs. Uses a 24-hour clock.
@export_range(1, 24, 1)
var sunrise_hour: int = 7

## The hour when sunrise occurs. Uses a 24-hour clock.
@export_range(1, 24, 1)
var sunset_hour: int = 17

## The hour when sunrise occurs. Uses a 24-hour clock.
@export_range(1, 24, 1)
var noon_hour:int= 12

@export_group("Season")
# SPRING
@export_subgroup("Spring")
@export var SPRING_NIGHT := Color("#293652")
@export var SPRING_DAWN := Color("#e79a83")
@export var SPRING_DAY := Color("#fff8ed")
@export var SPRING_DUSK := Color("#cf7b73")

@export_subgroup("Summer")
@export var SUMMER_NIGHT := Color("#202f50")
@export var SUMMER_DAWN := Color("#f2a066")
@export var SUMMER_DAY := Color("#fffdf2")
@export var SUMMER_DUSK := Color("#d66b4f")

# FALL
@export_subgroup("Fall")
@export var FALL_NIGHT := Color("#302f46")
@export var FALL_DAWN := Color("#d9825b")
@export var FALL_DAY := Color("#fff2dc")
@export var FALL_DUSK := Color("#b85c49")

# WINTER
@export_subgroup("Winter")
@export var WINTER_NIGHT := Color("#26354d")
@export var WINTER_DAWN := Color("#c99aa3")
@export var WINTER_DAY := Color("#e9f2f5")
@export var WINTER_DUSK := Color("#887d9e")

func get_season_colors(season) -> Dictionary:
	match season:
		"spring":
			return {
				"night": SPRING_NIGHT,
				"dawn": SPRING_DAWN,
				"day": SPRING_DAY,
				"dusk": SPRING_DUSK
			}

		"summer":
			return {
				"night": SUMMER_NIGHT,
				"dawn": SUMMER_DAWN,
				"day": SUMMER_DAY,
				"dusk": SUMMER_DUSK
			}

		"fall":
			return {
				"night": FALL_NIGHT,
				"dawn": FALL_DAWN,
				"day": FALL_DAY,
				"dusk": FALL_DUSK
			}

		"winter":
			return {
				"night": WINTER_NIGHT,
				"dawn": WINTER_DAWN,
				"day": WINTER_DAY,
				"dusk": WINTER_DUSK
			}

	return {
		"night": SPRING_NIGHT,
		"dawn": SPRING_DAWN,
		"day": SPRING_DAY,
		"dusk": SPRING_DUSK
	}

func _ready() -> void:

	DayCycle.time_changed.connect(_on_date_change)

func _on_date_change(day, hour, minute, season, year):
	var colors = get_season_colors(season)

	var night_color: Color = colors["night"]
	var dawn_color: Color = colors["dawn"]
	var day_color: Color = colors["day"]
	var dusk_color: Color = colors["dusk"]
	var current_time: float = hour + (minute / 60.0)

	var dawn_start: float = sunrise_hour - 1.0
	var sunrise_end: float = sunrise_hour + 1.0

	var dusk_start: float = sunset_hour - 1.0
	var sunset_end: float = sunset_hour + 1.0


	if current_time < dawn_start:
		# NIGHT
		color = night_color

		shadows.material.set_shader_parameter("angle", 90.0)
		shadows.material.set_shader_parameter("max_dist", 0.0)


	elif current_time < sunrise_hour:
		# NIGHT -> DAWN
		var progress := inverse_lerp(
			dawn_start,
			sunrise_hour,
			current_time
		)

		# Shadows start growing
		var shadow_length = lerp(0.0, 20.0, progress)

		shadows.material.set_shader_parameter("angle", 90.0)
		shadows.material.set_shader_parameter("max_dist", shadow_length)

		color = night_color.lerp(dawn_color, progress)



	elif current_time < sunrise_end:
		# DAWN -> DAY
		var progress := inverse_lerp(
			sunrise_hour,
			sunrise_end,
			current_time
		)

		# Rotate shadow as sun rises
		var angle = lerp(90.0, 100.0, progress)

		shadows.material.set_shader_parameter("angle", angle)
		shadows.material.set_shader_parameter("max_dist", 20.0)

		color = dawn_color.lerp(day_color, progress)

	elif current_time < noon_hour: 
		var progress := inverse_lerp(
			sunrise_end,
			noon_hour,
			current_time
		)

		# Rotate shadow as sun rises
		var angle = lerp(100.0, 180.0, progress)
		var shadow_length = lerp(20.0, 2.0, progress)
		shadows.material.set_shader_parameter("angle", angle)
		shadows.material.set_shader_parameter("max_dist",shadow_length)

		color = day_color
	elif current_time < dusk_start:
		# DAY
		color = day_color

		# Move shadow gradually throughout daytime
		var progress := inverse_lerp(
			noon_hour,
			dusk_start,
			current_time
		)

		var angle = lerp(180.0, 240.0, progress)
		var dist = lerp(2.0, 20.0, progress)
		shadows.material.set_shader_parameter("angle", angle)
		shadows.material.set_shader_parameter("max_dist", dist)


	elif current_time < sunset_hour:
		# DAY -> DUSK
		var progress := inverse_lerp(
			dusk_start,
			sunset_hour,
			current_time
		)

		var angle = lerp(240.0, 270.0, progress)
		var dist = lerp(20.0, 25.0, progress)
		shadows.material.set_shader_parameter("angle", angle)
		shadows.material.set_shader_parameter("max_dist", dist)

		color = day_color.lerp(dusk_color, progress)


	elif current_time < sunset_end:
		# DUSK -> NIGHT
		var progress := inverse_lerp(
			sunset_hour,
			sunset_end,
			current_time
		)

		# Fade/shrink shadows
		var shadow_length = lerp(25.0, 0.0, progress)

		shadows.material.set_shader_parameter("angle", 270.0)
		shadows.material.set_shader_parameter("max_dist", shadow_length)

		color = dusk_color.lerp(night_color, progress)


	else:
		# NIGHT
		color = night_color

		shadows.material.set_shader_parameter("angle", 270.0)
		shadows.material.set_shader_parameter("max_dist", 0.0)

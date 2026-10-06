extends Node

# ============================================================
# TIME CONFIGURATION
# ============================================================

# How many real-world seconds equal one in-game minute.
var SECOND_PER_MINUTES: float = 0.1

const MINUTES_PER_HOUR: int = 60
const HOURS_PER_DAY: int = 24
const DAYS_PER_SEASON: int = 30

const SEASONS: Array[String] = [
	"Spring",
	"Summer",
	"Fall",
	"Winter"
]

const SEASONS_PER_YEAR: int = 4
const DAYS_PER_YEAR: int = DAYS_PER_SEASON * SEASONS_PER_YEAR


# ============================================================
# CURRENT DATE / TIME
# ============================================================

var day: int = 1
var hour: int = 6
var minute: int = 0

# 0 = Spring
# 1 = Summer
# 2 = Fall
# 3 = Winter
var season: int = 0

var season_name: String = SEASONS[season]
var year: int = 1

var _time_accumulator: float = 0.0

var freez: bool = false


# ============================================================
# SIGNALS
# ============================================================

signal time_changed(day, hour, minute, season, year)
signal day_changed(day)
signal season_changed(season)
signal year_changed(year)


# ============================================================
# PROCESS
# ============================================================

func _process(delta: float) -> void:
	if freez:
		return

	_time_accumulator += delta

	while _time_accumulator >= SECOND_PER_MINUTES:
		_time_accumulator -= SECOND_PER_MINUTES
		advance_minute()


# ============================================================
# SET DAY LENGTH
# ============================================================

func day_length(
	day_length_in_second: float = 0,
	hour_length_in_second: float = 0,
	minute_length_in_second: float = 0
) -> void:

	if day_length_in_second > 0:
		SECOND_PER_MINUTES = day_length_in_second / (HOURS_PER_DAY * MINUTES_PER_HOUR)

	elif hour_length_in_second > 0:
		SECOND_PER_MINUTES = hour_length_in_second / MINUTES_PER_HOUR

	elif minute_length_in_second > 0:
		SECOND_PER_MINUTES = minute_length_in_second


# ============================================================
# ADVANCE TIME BY ONE MINUTE
# ============================================================

func advance_minute() -> void:
	minute += 1

	# --------------------------------------------------------
	# New hour
	# --------------------------------------------------------

	if minute >= MINUTES_PER_HOUR:
		minute = 0
		hour += 1

	# --------------------------------------------------------
	# New day
	# --------------------------------------------------------

	if hour >= HOURS_PER_DAY:
		hour = 0
		advance_day()

	emit_signal(
		"time_changed",
		day,
		hour,
		minute,
		season,
		year
	)


# ============================================================
# ADVANCE DAY
# ============================================================

func advance_day() -> void:
	day += 1

	# --------------------------------------------------------
	# New season
	# --------------------------------------------------------

	if day > DAYS_PER_SEASON:
		day = 1
		season += 1

		# ----------------------------------------------------
		# New year
		# ----------------------------------------------------

		if season >= SEASONS_PER_YEAR:
			season = 0
			year += 1

			emit_signal("year_changed", year)

		season_name = SEASONS[season]

		emit_signal("season_changed", season)

	emit_signal("day_changed", day)

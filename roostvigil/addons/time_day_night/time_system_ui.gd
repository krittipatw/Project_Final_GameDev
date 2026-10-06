extends PanelContainer

@onready var time: Label = %time
@onready var date: Label = %date
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	DayCycle.time_changed.connect(_on_date_change)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_date_change(day,hour,minute,season,year):
	var ampm = "PM" if hour >= 12 else "AM"
	var hours= hour if hour <13 else hour-12
	time.text=str("%02d" %hours)+":"+str("%02d" % minute)+ampm
	date.text=str(day)+" "+str(DayCycle.season_name)

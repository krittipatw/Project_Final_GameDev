extends PanelContainer
@onready var currentvalue: Label = $VBoxContainer/currentvalue
@onready var h_slider: HSlider = $VBoxContainer/HSlider


# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	DayCycle.day_length(0,0,h_slider.value)
	currentvalue.text=str(h_slider.value)+"seconds per minutes"
func _on_h_slider_value_changed(value: float) -> void:
	DayCycle.day_length(0,0,value)
	currentvalue.text=str(value)+" seconds per minutes"


func _on_check_button_toggled(toggled_on: bool) -> void:
	DayCycle.freez=toggled_on

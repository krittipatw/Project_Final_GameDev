extends CanvasLayer

@onready var title_label: Label = $Control/Panel/TitleLabel
@onready var content_label: RichTextLabel = $Control/Panel/ContentLabel
@onready var close_button: Button = $Control/Panel/CloseButton

func _ready() -> void:
	print("NotebookUI ready")  # ลบทิ้งได้เมื่อทำงานปกติแล้ว
	add_to_group("notebook_ui")
	hide()
	close_button.pressed.connect(close_notebook)

func show_note(note_title: String, note_content: String) -> void:
	title_label.text = note_title
	content_label.text = note_content
	show()
	# ปลดล็อกเมาส์เพื่อให้คลิกปุ่มปิดได้
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close_notebook() -> void:
	hide()
	# คืนเมาส์กลับไปโหมดเล่นเกม
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_notebook()
		get_viewport().set_input_as_handled()

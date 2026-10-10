extends CanvasLayer

@onready var panel: Control = $Control/Panel
@onready var title_label: Label = $Control/Panel/TitleLabel
@onready var content_label: RichTextLabel = $Control/Panel/ContentLabel
@onready var close_button: Button = $Control/Panel/CloseButton

func _ready() -> void:
	# ซ่อน UI ตอนเริ่มเกม
	hide()
	# เพิ่มตัวเองเข้ากลุ่ม "notebook_ui" เพื่อให้ Notebook.gd เรียกใช้งานได้
	add_to_group("notebook_ui")
	
	# เชื่อมสัญญาณปุ่มปิดอัตโนมัติ
	close_button.pressed.connect(_on_close_button_pressed)

func show_note(notebook_title: String, notebook_content: String) -> void:
	title_label.text = notebook_title
	content_label.text = notebook_content
	show()
	
	# ปลดล็อกเมาส์เพื่อให้ผู้เล่นคลิกปุ่มปิดได้
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event: InputEvent) -> void:
	# กด ESC เพื่อปิดสมุด
	if visible and event.is_action_pressed("ui_cancel"):
		close_notebook()

func _on_close_button_pressed() -> void:
	close_notebook()

func close_notebook() -> void:
	hide()
	# คืนค่าเมาส์กลับไปเป็นโหมดล็อกเพื่อเล่นเกมต่อ
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

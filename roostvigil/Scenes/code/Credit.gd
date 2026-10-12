extends Control

@export var speed: float = 60.0              # ความเร็วเลื่อน (พิกเซล/วินาที)
@export var fast_multiplier: float = 4.0     # กดค้าง Enter/Space เพื่อเร่งความเร็ว
@export_file("*.tscn") var next_scene: String = "res://Scenes/main_menu.tscn"

@export_multiline var credits_text: String = """[center][font_size=64]Roost Vigil[/font_size]

[center][font_size=36]Background[/font_size]
[font_size=28]Forest
- Author: rhfqcntrkf
- License: CC BY 4.0[/font_size]


[font_size=36]Object[/font_size]
[font_size=28]Watch tower Remastered Wide 
- Author: 00amza
- License: CC BY 4.0

Vintage Radio 
- Author: MinFeng
- License: CC BY 4.0

Flashlight 
- Author: sookendestroy1
- License: CC BY 4.0

Flashlight Battery 
- Author: CanVas Dev
- License: CC BY 4.0

Led Ceiling Light 
- Author: nikki.patel59896
- License: CC BY 4.0

Tumblers 
- Author: blenderist
- License: CC BY 4.0

Plan Student's record book Залікова студента
- Author: Laryok_k
- License: CC BY 4.0][/font_size]


[font_size=36]Ghost[/font_size]
[font_size=28]Ghost Girl Animated 
- Author: Shaban Hafizsalim
- License: CC BY 4.0

Smily horror monster 
- Author: Bento 
- License: CC BY 4.0

Horror Skunx Retexterd Siren Head [UPDATED] 
- Author: Horror BigGameRR Green Screens
- License: CC BY 4.0

Grandpa animated Make Joke Horror Gulli Bulli 
- Author: Make Joke Horror Official
- License: CC BY 4.0

Jötunn creature inspired by "The ritual"  
- Author: ps2enthusiast
- License: CC BY 4.0


[font_size=36]Members[/font_size]
- นายกฤติพัฒน์ หวังมะโน 683380065-7
- นายพีรัชชัย เจริญตา 683380088-5
- นายพงศธร นันทะ 683380307-9
-นางสาวมุกรวี เจนกุลประสูตร 683380586-9 

Thank you for playing[/font_size][/center]"""

@onready var credits: RichTextLabel = $credit
@onready var exit_button: Button = $exit

var _done := false


func _ready() -> void:
	
	credits.bbcode_enabled = true
	credits.fit_content = true
	credits.scroll_active = false
	credits.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# กว้าง 80% ของจอ (สูงสุด 900) แล้ววางกลางจอ
	credits.size.x = minf(size.x * 0.8, 900.0)
	credits.position.x = (size.x - credits.size.x) / 2.0
	credits.text = credits_text

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)   # ให้เห็นเมาส์เพื่อกดปุ่ม
	exit_button.pressed.connect(_finish)

	credits.bbcode_enabled = true
	credits.fit_content = true

	# รอ 1 เฟรมให้ความสูงคำนวณเสร็จ แล้วเริ่มจากใต้ขอบล่าง
	await get_tree().process_frame
	credits.position.y = size.y


func _process(delta: float) -> void:
	if _done:
		return

	var mult := fast_multiplier if Input.is_action_pressed("ui_accept") else 1.0
	credits.position.y -= speed * mult * delta

	# เลื่อนพ้นขอบบนหมดแล้ว
	if credits.position.y + credits.get_content_height() < 0.0:
		_finish()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # กด Esc เพื่อข้าม
		_finish()


func _finish() -> void:
	_done = true
	get_tree().change_scene_to_file(next_scene)

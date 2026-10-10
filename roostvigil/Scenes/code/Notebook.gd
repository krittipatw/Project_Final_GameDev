extends StaticBody3D

@export var notebook_title: String = "Notebook"
@export_multiline var notebook_content: String = """
Day 01

Something strange happened here...
"""

func get_prompt() -> String:
	return notebook_title

func interact(_player = null) -> void:
	var ui = get_tree().get_first_node_in_group("notebook_ui")
	if ui:
		ui.show_note(notebook_title, notebook_content)
	else:
		push_warning("ไม่พบ NotebookUI ใน group notebook_ui")

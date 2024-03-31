extends LineEdit

var is_changing: bool


func _ready() -> void:
	text_submitted.connect(on_text_submitted)
	focus_entered.connect(start_edit)


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("change_name"): return
	if is_changing: return
	
	start_edit.call_deferred()


func start_edit() -> void:
	is_changing = true
	EditMode.set_enabled(true)
	grab_click_focus()
	grab_focus()
	caret_column = text.length()


func on_text_submitted(_text: String) -> void:
	is_changing = false
	EditMode.set_enabled(false)
	release_focus()

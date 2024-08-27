@tool
extends EditorProperty


static var _highlighter: SyntaxHighlighter

var _hbox: HBoxContainer
var _code_edit: CodeEdit
var _big_window: AcceptDialog
var _big_code_edit: CodeEdit


func _init() -> void:
	_code_edit = CodeEdit.new()
	_code_edit.syntax_highlighter = _get_highlighter()
	_code_edit.gutters_draw_line_numbers = true
	_code_edit.draw_tabs = true
	_code_edit.custom_minimum_size.y = 128.0
	_code_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	@warning_ignore("return_value_discarded")
	_code_edit.text_changed.connect(_on_code_edit_text_changed)

	var button: Button = Button.new()
	button.icon = EditorInterface.get_editor_theme().get_icon(&"DistractionFree", &"EditorIcons")
	@warning_ignore("return_value_discarded")
	button.pressed.connect(_show_big_window)

	_hbox = HBoxContainer.new()
	_hbox.add_child(_code_edit)
	_hbox.add_child(button)


func _init_big_window() -> void:
	_big_code_edit = CodeEdit.new()
	_big_code_edit.syntax_highlighter = _get_highlighter()
	_big_code_edit.gutters_draw_line_numbers = true
	_big_code_edit.draw_tabs = true
	@warning_ignore("return_value_discarded")
	_big_code_edit.text_changed.connect(_on_big_code_edit_text_changed)

	_big_window = AcceptDialog.new()
	_big_window.title = "Edit Code:"
	_big_window.add_child(_big_code_edit)

	add_child(_big_window)


func _exit_tree() -> void:
	assert(_hbox.get_parent())


func _set_read_only(p_read_only: bool) -> void:
	_code_edit.editable = not p_read_only
	if _big_code_edit:
		_big_code_edit.editable = not p_read_only


func _update_property() -> void:
	var text: String = get_edited_object().get(get_edited_property())
	_code_edit.text = text
	if _big_code_edit:
		_big_code_edit.text = text


func get_custom_control() -> Control:
	return _hbox


func _get_highlighter(attempt: int = 1) -> SyntaxHighlighter:
	if Engine.get_version_info().hex >= 0x040400:
		return ClassDB.instantiate(&"GDScriptSyntaxHighlighter")

	if _highlighter:
		return _highlighter

	if attempt > 2:
		push_error("Failed to get GDScriptSyntaxHighlighter.")
		return SyntaxHighlighter.new()

	var script_editor: ScriptEditor = EditorInterface.get_script_editor()
	var scripts: Array[Script] = script_editor.get_open_scripts()
	for i: int in scripts.size():
		if scripts[i] is GDScript:
			var editors: Array[ScriptEditorBase] = script_editor.get_open_script_editors()
			var base_editor: CodeEdit = editors[i].get_base_editor()
			var highlighter: SyntaxHighlighter = base_editor.syntax_highlighter
			assert(highlighter.get_class() == "GDScriptSyntaxHighlighter")
			_highlighter = highlighter
			return highlighter

	EditorInterface.edit_script(preload("./stub.gd"))
	return _get_highlighter(attempt + 1)


func _show_big_window() -> void:
	if not _big_window:
		_init_big_window()
	_big_code_edit.text = _code_edit.text
	_big_window.popup_centered_clamped(Vector2(1000, 900), 0.8)
	_big_code_edit.grab_focus()


func _on_code_edit_text_changed() -> void:
	emit_changed(get_edited_property(), _code_edit.text, &"", true)


func _on_big_code_edit_text_changed() -> void:
	_code_edit.text = _big_code_edit.text
	emit_changed(get_edited_property(), _big_code_edit.text, &"", true)

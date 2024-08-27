@tool
extends EditorInspectorPlugin


const _EditorProperty = preload("./editor_property.gd")


func _can_handle(_object: Object) -> bool:
	return true


func _parse_property(_object: Object, type: Variant.Type, name: String, hint_type: PropertyHint,
		hint_string: String, _usage_flags: int, _wide: bool) -> bool:
	if type == TYPE_STRING and hint_type == PROPERTY_HINT_MULTILINE_TEXT \
			and hint_string == "lang=gdscript":
		var editor_property: _EditorProperty = _EditorProperty.new()
		add_property_editor(name, editor_property)
		add_custom_control(editor_property.get_custom_control())
		return true
	return false

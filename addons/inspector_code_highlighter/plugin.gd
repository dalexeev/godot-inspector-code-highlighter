@tool
extends EditorPlugin


const _InspectorPlugin = preload("./inspector_plugin.gd")

var _inspector_plugin: _InspectorPlugin = _InspectorPlugin.new()


func _enter_tree() -> void:
	add_inspector_plugin(_inspector_plugin)


func _exit_tree() -> void:
	remove_inspector_plugin(_inspector_plugin)

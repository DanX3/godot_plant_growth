extends Button

@export var grow_tool: GrowTool

func _on_pressed():
#	state = GrowState.SelectOrigin
	grow_tool.set_state(GrowTool.GrowState.SelectOrigin)
	print("grow state: select origin")

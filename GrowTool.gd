extends Node2D

class_name GrowTool

enum GrowState {
	None, # inactive
	SelectOrigin, # showing cursor to closest plant point
	SelectDir, # showing arrow to choose direction
}

# closest point to the cursor
var origin_point: Vector2
# selected direction
var selected_direction: Vector2
# state of the tool
var state = GrowState.None
var selected_branch: Branch
var selected_point_index: int

@export var branch_scene: PackedScene
@onready var cursor: Control = $CursorUI
@onready var arrow: Control = $Arrow

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	print("global mouse pos: ", get_global_mouse_position())
#	print("nodes count in group plant:", get_tree().get_nodes_in_group("plant").size())
	if state == GrowState.SelectOrigin:
		var min_dist = INF
		origin_point = Vector2.ZERO
		for plant in get_tree().get_nodes_in_group("plant"):
#			for p in (plant as Branch).points:
			var branch_points = (plant as Branch).points
			for i in range(branch_points.size()):
				var p = branch_points[i]
				var p_global = (plant as Node2D).to_global(p)
				var dist = (get_global_mouse_position() - p_global).length_squared()
				if dist < min_dist:
					min_dist = dist
					origin_point = p_global
					selected_branch = plant
					selected_point_index = i
					
					
#					print("found closer point " + str(p) + " to mouse " + str(get_global_mouse_position()))
		cursor.position = get_canvas_transform() * origin_point
	elif state == GrowState.SelectDir:
		arrow.position = get_canvas_transform() * origin_point
		selected_direction = (get_global_mouse_position() - origin_point).normalized()
		arrow.rotation = atan2(selected_direction.y, selected_direction.x)
		

func _unhandled_input(event):
	if Input.is_action_just_pressed("mouse_click") and state == GrowState.SelectOrigin:
		set_state(GrowState.SelectDir)
	elif Input.is_action_just_pressed("mouse_click") and state == GrowState.SelectDir:
		set_state(GrowState.None)
		var new_branch = branch_scene.instantiate() as Branch
		selected_branch.add_child(new_branch)
		new_branch.global_position = origin_point
		new_branch.init(Branch.DoubleBend(Vector2.ZERO, 200.0 * selected_direction))

func set_state(state: GrowState):
	_on_state_exit(self.state)
	self.state = state
	_on_state_enter(state)

func _on_state_exit(old_state: GrowState):
	print("exited state: " + str(old_state))
	match old_state:
		GrowState.SelectOrigin:
			cursor.hide()
		GrowState.SelectDir:
			arrow.hide()

func _on_state_enter(new_state: GrowState):
	print("entered state: " + str(new_state))
	match state:
		GrowState.SelectOrigin:
			cursor.show()
		GrowState.SelectDir:
			arrow.show()

func _on_button_pressed():
	set_state(GrowState.SelectOrigin)

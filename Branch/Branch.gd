extends Line2D

class_name Branch

@export var branch_scene: PackedScene
#@export var point: PackedScene
@export var length = 100.0
@export var points_count = 20
@export var grow_on_ready = false
var target: Vector2
var dir: Vector2
var p: Array[Vector2] # points of the branch

# interval used to spawn new branches
# ex: growth_branch_step = 0.2 will spawn 5 branches
# ex: growth_branch_step = 0.5 will spawn 2 branches
var growth_branch_step = -1.0
var branches_spawned = 0

func _enter_tree():
	add_to_group("plant")

func _ready():
	if grow_on_ready:
		init(DoubleBend(Vector2(0, 0), Vector2(0, -300)))

func init(points: Array[Vector2]):
	assert(points.size() == 4, "Provided points in Branch.init(...) must be 4")
	p = points
	dir = (points[3] - points[0]).normalized()
	length = (points[3] - points[0]).length()
	
	var tween = get_tree().create_tween()
	tween.tween_method(grow, 0.0, 1.0, 2.0)

func easeInOutQuad(x: float) -> float:
	if x < 0.5:
		return 2.0 * x * x
	else:
		return 1 - 0.5 * pow(-2.0 * x + 2.0, 2)

func grow(branch_growth: float):
	clear_points()
	for i in range(points_count):
		var t = branch_growth * float(i) / points_count
		t = easeInOutQuad(t)
		add_point(bezier_cubic(p[0], p[1], p[2], p[3],  t))
	
	# spawn new branch
#	if growth_branch_step > 0 and branch_growth > growth_branch_step * branches_spawned:
#		branches_spawned += 1
#		print(name)
#		var new_branch = branch_scene.instantiate() as Branch
#		new_branch.name = "SubBranch" + str(branches_spawned)
#		add_child(new_branch)
#		new_branch.init(points[points.size() - 2], \
#			(1.0 - growth_branch_step * branches_spawned) * length,
#			dir.rotated(randf_range(-0.2 * PI, +0.2 * PI)))
#		print("length: ", (1.0 - growth_branch_step * branches_spawned) * length)
		

func bezier_quadratic(p0, p1, p2, i):
	return (1.0 - i) * ((1.0 - i) * p0 + i * p1) + i * ((1.0 - i) * p1 + i * p2)

func bezier_cubic(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, i: float):
	var oneMinusI = 1.0 - i

# 	TODO: write better this formula
	return oneMinusI * oneMinusI * oneMinusI * p0 \
		+ 3.0 * oneMinusI * oneMinusI * i * p1 + \
		+ 3.0 * oneMinusI * i * i * p2 \
		+ i * i * i * p3

#func _draw():
#	draw_line(p[0], p[1], Color.RED)
#	draw_line(p[1], p[2], Color.RED)
#	draw_line(p[2], p[3], Color.RED)

static func DoubleBend(origin: Vector2, target: Vector2) -> Array[Vector2]:
	var dir = (target - origin).normalized()
	var ortho = dir.orthogonal()
	var length = (target - origin).length()
	var amplitude = 0.5 * length
	return [origin,
		0.25 * length * dir + amplitude * ortho,
		0.75 * length * dir + amplitude * -ortho,
		target
	]

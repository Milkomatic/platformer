extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const H_LOOK_SENS = 0.7
var to_rot = 180
var is_facing_right = false;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y += event.relative.x * H_LOOK_SENS

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_pressed("move_forwards"):
		to_rot = 180.0		
		var is_facing_right = false;
	if Input.is_action_pressed("move_backwards"):
		to_rot = 360
		to_rot = 0
		var is_facing_right = false;
	if Input.is_action_pressed("move_right"):
		to_rot = 90.0
		var is_facing_right = true;
	if Input.is_action_pressed("move_left"):
		to_rot = 270.0
		var is_facing_right = false;
	
	rotation_degrees.y = lerp(rotation_degrees.y, to_rot, .2)
	# Interpolate using spherical-linear interpolation (SLERP).
#	var current_faceing = rotation
#	var slerp_look = current_faceing.slerp(look_vec,0.5) # find halfway point between a and b




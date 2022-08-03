extends SpringArm

const H_MOUSE_SENS = 0.7
const V_MOUSE_SENS = 0.7
const H_STICK_SENS = 3
const V_STICK_SENS = 3

const AUTO_R_DELAY = 1
const AUTO_R_SPEED = .2
const AUTO_R_ANGLE = .01
var auto_r_delay_counter = 0.0
var has_input = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * V_MOUSE_SENS
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 30)	
		rotation_degrees.y -= event.relative.x * H_MOUSE_SENS
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360)
		has_input = true
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input_rotation = Vector2(
		Input.get_action_strength("camera_down") - Input.get_action_strength("camera_up"),
		Input.get_action_strength("camera_right") - Input.get_action_strength("camera_left")
	)
	rotation_degrees.x -= input_rotation.x * V_STICK_SENS 
	rotation_degrees.y -= input_rotation.y * H_STICK_SENS 
	rotation_degrees.x = clamp(rotation_degrees.x, -90, 30)	
	rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360)
	
	if input_rotation != Vector2.ZERO:
		has_input
		
#	p_auto_rotate(delta)


func p_auto_rotate(delta: float):
	if has_input:
		auto_r_delay_counter = 0
	else:
		auto_r_delay_counter += delta
		if(auto_r_delay_counter >= AUTO_R_DELAY):
			var dir = get_parent().get_node("Graphics").rotation_degrees
			dir.x = clamp(dir.x, -90, 30)	
			dir.y = wrapf(dir.y, 0.0, 360)
			print(dir)
#			rotation_degrees = lerp(rotation_degrees, -dir, AUTO_R_SPEED)
			rotation_degrees.y = dir.y
#			var dir = get_parent().translation
#			look_at(dir, Vector3.UP)
	has_input = false
	

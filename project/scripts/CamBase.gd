extends SpringArm

const H_MOUSE_SENS = 0.7
const V_MOUSE_SENS = 0.7
const H_STICK_SENS = 5
const V_STICK_SENS = 5

const AUTO_R_DELAY = 1.5
const AUTO_R_SPEED = .04
const AUTO_R_ANGLE = .05
var auto_r_delay_counter = 0.0
var has_input = false
var angle_to_rotate = 0.0

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
		has_input = true
		
	p_auto_rotate(delta)


func p_auto_rotate(delta: float):
	if has_input:
		auto_r_delay_counter = 0
	else:
		auto_r_delay_counter += delta
		if(auto_r_delay_counter >= AUTO_R_DELAY):
			var facing_vec = get_parent().facing_vec
			var player_forward = Vector2(-facing_vec.x, -facing_vec.z)
			var cam_aim = get_global_transform().basis.z
			var cam_forward = Vector2(cam_aim.x, cam_aim.z)
			var angle_diff = player_forward.angle_to(cam_forward)		
			if(abs(angle_diff) > AUTO_R_ANGLE):
#				angle_to_rotate = lerp(angle_to_rotate, angle_diff, AUTO_R_SPEED)
#				rotate_y(angle_to_rotate)
				rotate_y(angle_diff * AUTO_R_SPEED)
#			else:
#				auto_r_delay_counter = 0

	has_input = false
	

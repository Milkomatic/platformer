extends SpringArm

const H_MOUSE_SENS = 0.7
const V_MOUSE_SENS = 0.7
const H_STICK_SENS = 3
const V_STICK_SENS = 3

const AUTO_R_DELAY = 1
const AUTO_R_SPEED = .002
const AUTO_R_ANGLE = .01
var auto_r_delay_counter = 0.0
var has_input = false
var lerp_face

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
		
	p_auto_rotate(delta)


func p_auto_rotate(delta: float):
	if has_input:
		auto_r_delay_counter = 0
	else:
		auto_r_delay_counter += delta
		if(auto_r_delay_counter >= AUTO_R_DELAY):
#			var dir = get_parent().get_node("demo-man").rotation
			var facing_vec = get_parent().facing_vec
#			var aim = get_global_transform().basis
#			var forward = -aim.z
#			var dir_vec = Vector2(facing_vec.x, facing_vec.z)
			var dir_vec = Vector3(facing_vec.x, 0 ,facing_vec.z)
#			dir.x = clamp(dir.x, -90, 30)	
#			var angl = wrapf(dir_vec.angle(), 0.0, 1.0)
#			print(angl)
#			rotation.y = lerp(rotation.y, -dir.y, AUTO_R_SPEED)
#			rotation_degrees.y = dir.y
#			var dir = get_parent().translation
			var lerp_face = lerp(lerp_face, dir_vec, AUTO_R_SPEED)
			look_at(global_transform.origin + lerp_face, Vector3.UP)

	has_input = false
	

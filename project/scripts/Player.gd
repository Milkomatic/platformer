class_name Player
extends KinematicBody

const MAX_STAMINA := 120.0
const MAX_BUFFER := 360.0
const MAX_EXHAUSTION := 60.0
const STAMINA_RECOVERY := 3 #2?
const EXHAUSTION_RECOVERY := .2 #.75?

const DASH_STAM_COST := 30
#const DASH_STAM_COST := 40
const WALL_JUMP_STAM_COST := 12
const AIR_JUMP_STAM_COST := 60

const WALL_RUN_STAM_DRAIN := .25 # should sliding/running cost stamina?

const MAX_SPEED := 15
const JUMP_FORCE := 30
const DASH_FORCE := 45
const DASH_LENGTH := 16
const H_WALL_JUMP_FORCE := 28 #slightly higher than H to make sure player cant climb
const V_WALL_JUMP_FORCE := 20 
const AIR_JUMP_FORCE := 25 # same as v_wall force. you get the same upward movement for more stam if you dont use a wall
const GRAVITY := 0.98
const WALL_SLIDE_SPEED := 5
const MAX_FALL_SPEED := 30
const MAX_WALL_SLIDE_SPEED := 5
const MAX_WALL_RUN_SLIDE_SPEED := 2.5

const RUN_SPEED_MOD := 0.10
const AIR_SPEED_MOD := 0.06
const WALL_SPEED_MOD := 0.06

const TURN_MOD = 0.2

onready var cam = $CamBase
onready var anim = $Graphics/AnimationPlayer
onready var graphics = $Graphics
onready var demo = $"demo-man"
onready var stam_bar = $Hud/StaminaBar
onready var exh_bar = $Hud/ExhaustionBar
onready var buf_bar = $Hud/BufferBar

onready var head_box = $HeadBox
onready var mid_box = $MidBox
onready var hook_box = $HookBox
onready var foot_box = $FootBox

var y_velo = 0.0
# might make all the following vecs 2d to ignore up/down
var move_vec := Vector3()
var facing_vec := Vector3()

var stamina := MAX_STAMINA
var exhaustion := 0.0
var buffer := MAX_BUFFER

func _ready():
	anim.get_animation("walk").set_loop(true)
	stam_bar.max_value = MAX_STAMINA
	buf_bar.max_value = MAX_BUFFER

func _physics_process(delta):
	p_hud()

func p_hud():
	stam_bar.value = lerp(stam_bar.value, stamina, .4)
	exh_bar.value = lerp(exh_bar.value, exhaustion, .4)
	buf_bar.value = lerp(buf_bar.value, buffer, .4)
	cam.translation = lerp(cam.translation, translation + Vector3.UP*1.5, 0.4) #one*1.5 unit up
	
func spend_stamina(value: float):
	stamina -= value
	if stamina <= 0:
		buffer += stamina # stamina is negative here
		exhaustion = -buffer
		stamina = 0
	if buffer < 0:
		buffer = 0


func get_input_vec() -> Vector3:
	var input_vec = Vector3()	
	input_vec.x = Input.get_action_strength("move_right") -  Input.get_action_strength("move_left")
	input_vec.z = Input.get_action_strength("move_backwards") -  Input.get_action_strength("move_forwards")
	input_vec = input_vec.rotated(Vector3(0, 1, 0), cam.rotation.y)
	return input_vec

#func do_facing(input_vec: Vector3):
#	facing_vec = lerp(facing_vec, input_vec , TURN_MOD)
#	graphics.look_at(global_transform.origin - facing_vec, Vector3(0, 1, 0))
#	graphics.rotation.y = lerp( graphics.rotation.y, atan2( input_vec.x, input_vec.z ), TURN_MOD) 

func do_recover():
	if exhaustion > 0:
		exhaustion -= EXHAUSTION_RECOVERY 
	else:
		stamina += STAMINA_RECOVERY
		if stamina > MAX_STAMINA:
			stamina = MAX_STAMINA

func do_momentum_move(input_vec: Vector3, target_speed: float, change_rate: float,
		 snap_vector := Vector3.DOWN, up_vector := Vector3.UP):
	move_vec = lerp(move_vec, input_vec * target_speed, change_rate)
	var real_move_vec = Vector3(move_vec.x, y_velo, move_vec.z)		
	move_and_slide_with_snap(real_move_vec, snap_vector, up_vector, true, 4, deg2rad(80), false)
	if not is_equal_approx(input_vec.length(), 0.0):
		facing_vec = lerp(facing_vec, input_vec , TURN_MOD)
		graphics.look_at(global_transform.origin - facing_vec, Vector3(0, 1, 0))
#		demo.look_at(global_transform.origin - facing_vec, Vector3(0, 1, 0))

func play_anim(name):
	if anim.current_animation == name:
		return
	anim.play(name)

func is_hooked():
	return (!hook_box.get_overlapping_areas().empty())

func is_grounded():
	return (!foot_box.get_overlapping_bodies().empty())
	
func is_walled():	
	return (foot_box.get_overlapping_bodies().empty() and !mid_box.get_overlapping_bodies().empty() and !head_box.get_overlapping_bodies().empty())

func is_only_grounded():
	return (!foot_box.get_overlapping_bodies().empty() and head_box.get_overlapping_bodies().empty())	

func is_sloped():
	return(!foot_box.get_overlapping_bodies().empty() and  !mid_box.get_overlapping_bodies().empty() and head_box.get_overlapping_bodies().empty())

func is_aired():
	return(foot_box.get_overlapping_bodies().empty() and  mid_box.get_overlapping_bodies().empty() and head_box.get_overlapping_bodies().empty())

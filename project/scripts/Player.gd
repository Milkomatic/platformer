extends KinematicBody

const MAX_STAMINA := 120.0
const STAMINA_RECOVERY := 3 #2?
const PENALTY_RECOVERY := .5 #.75?

const DASH_STAM_COST := 40
const WALL_JUMP_STAM_COST := 12
const AIR_JUMP_STAM_COST := 60

const WALL_RUN_STAM_DRAIN := 1 # should sliding/running cost stamina?

const MAX_SPEED := 15
const MAX_CROUCH_SPEED := 30
const JUMP_FORCE := 30
const DASH_FORCE := 45
const DASH_LENGTH := 10
const H_WALL_JUMP_FORCE := 22 #slightly higher than H to make sure player cant climb
const V_WALL_JUMP_FORCE := 20 
const AIR_JUMP_FORCE := 25 # same as v_wall force. you get the same upward movement for more stam if you dont use a wall
const GRAVITY := 0.98
const WALL_SLIDE_SPEED := 5
const MAX_FALL_SPEED := 30
const MAX_WALL_SLIDE_SPEED := 5

const SLIDE_DECELERATION := .025
const OVER_MAX_DECELERATION := .20

#maybe air and ground resistance 
const ACCELERATION := .05
const DECELERATION := .075
const AIR_ACCELERATION := .025
const AIR_DECELERATION := .05

const SPEED_MOD := 20
const AIR_SPEED_MOD := 20
const CROUCH_SPEED_MOD := 20
const WALL_SPEED_MOD := 12

const TURN_MOD := 0.06
const AIR_TURN_MOD := 1

onready var cam = $CamBase
onready var anim = $Graphics/AnimationPlayer
onready var graphics = $Graphics
onready var stam_bar = $Hud/StaminaBar
onready var pen_bar = $Hud/PenaltyBar

onready var head_box = $HeadBox
onready var mid_box = $MidBox
onready var foot_box = $FootBox

export(Curve) var acceleration_curve
export(Curve) var deceleration_curve
var speed_rate := 0.0 #value of 0-1

var y_velo = 0.0
# might make all the following vecs 2d to ignore up/down
var move_vec := Vector3()
var facing_vec := Vector3()
var dash_vec := Vector3()
var wall_jump_vec := Vector3()
var is_standing_still := true	
var stamina := MAX_STAMINA
var dash_cooldown := 0
var wall_jump_cooldown := 0
var input_freeze := 0

var jump_height := 0
var is_jumping := false
var is_falling := false
var is_crouching := false

func _ready():
	anim.get_animation("walk").set_loop(true)
	stam_bar.max_value = MAX_STAMINA
	
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#func _input(event):
#	if event is InputEventMouseMotion:
#		cam.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
#		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)	
#		rotation_degrees.y -= event.relative.x * H_LOOK_SENS
#		graphics.rotation_degrees.y += event.relative.x * H_LOOK_SENS

#func _process(delta):
#pass

func _physics_process(delta):
	var just_jumped = false
	var input_vec = get_input_vec()
#	p_state_tween_h_speed(input_vec)
	is_standing_still = (input_vec == Vector3())		
	
	p_facing(input_vec)

	p_dash(input_vec)
	just_jumped = p_jump(just_jumped)
	
	p_cooldowns()
	
	p_move()
	p_fall()
	
	p_animations(just_jumped)
	p_hud()

func p_animations(var just_jumped):
	if just_jumped:
		play_anim("jump")
	elif is_only_grounded():
		if is_standing_still:
			play_anim("idle")
		else:
			play_anim("walk")
			
func p_hud():
	stam_bar.value = stamina
	pen_bar.value = -stamina
	cam.translation = lerp(cam.translation, translation + Vector3.UP, 0.4) #one unit up
	
func get_input_vec() -> Vector3:
	var input_vec = Vector3()	
	input_vec.x = Input.get_action_strength("move_right") -  Input.get_action_strength("move_left")
	input_vec.z = Input.get_action_strength("move_backwards") -  Input.get_action_strength("move_forwards")
	input_vec = input_vec.rotated(Vector3(0, 1, 0), cam.rotation.y).normalized()
	
	if Input.is_action_pressed("crouch"):
		is_crouching = true
	else:
		is_crouching = false
	return input_vec

func p_facing(input_vec):
	if !is_standing_still:
		if dash_cooldown <= 0 and wall_jump_cooldown <= 0:
			facing_vec = lerp(facing_vec, input_vec , TURN_MOD)
		else:
			facing_vec = lerp(facing_vec, input_vec , TURN_MOD/3)			
		graphics.look_at(global_transform.origin - facing_vec, Vector3(0, 1, 0))

func p_dash(input_vec):
	if !is_standing_still and Input.is_action_just_pressed("dash") and stamina > 0 and dash_cooldown <= 0:
		dash_cooldown = DASH_LENGTH
#		move_vec = Vector3() #cut momentum
#		y_velo = 0 #stop jumping	#also stop falling
		dash_vec = input_vec * DASH_FORCE
		stamina -= DASH_STAM_COST

func p_jump(just_jumped) -> bool:
	if is_grounded(): # jump
		if y_velo<= 0:
			is_jumping = false;
		if Input.is_action_just_pressed("jump"):
			just_jumped = true
			is_jumping = true
			y_velo = JUMP_FORCE 
	elif is_walled(): # wall jump
		# get wall collision vector when first walled (move_vec/facing_vec) and store it until not walled
		if Input.is_action_just_pressed("jump") and stamina > 0:
			var test_collision = move_and_collide(facing_vec, true, true, true)
			if test_collision == null:	
				test_collision = move_and_collide(-facing_vec*4, true, true, true)
			if test_collision != null:	
				is_jumping = true
				y_velo = V_WALL_JUMP_FORCE
				wall_jump_cooldown = DASH_LENGTH
				wall_jump_vec = test_collision.normal * H_WALL_JUMP_FORCE
				stamina -= WALL_JUMP_STAM_COST
	elif is_aired(): # air jump
		if  y_velo > 0 and Input.is_action_just_released("jump"):
			y_velo = y_velo / 2
		if Input.is_action_just_pressed("jump") and stamina > 0:
			is_jumping = true						
			y_velo = 0 # cut current falling or jumping momentum
			y_velo = AIR_JUMP_FORCE #maybe a short few frame lerp to make a wind up pose
			stamina -= AIR_JUMP_STAM_COST
	return just_jumped

func p_cooldowns():
	if dash_cooldown <= 0: 
		dash_vec = lerp(dash_vec, Vector3(), .5)		
		if is_only_grounded():
			if stamina < 0:
				stamina += PENALTY_RECOVERY 
			else:
				stamina += STAMINA_RECOVERY
			if stamina > MAX_STAMINA:
				stamina = MAX_STAMINA	
	elif dash_cooldown > 0:
		dash_cooldown -= 1	
	
	if wall_jump_cooldown <= 0:
		wall_jump_vec -= wall_jump_vec * 0.1		
	elif wall_jump_cooldown > 0:
		facing_vec = Vector3() # cant move for a cooldown				
		wall_jump_cooldown -= 1	

func p_fall():
	if is_walled() and y_velo <= 0 and !is_crouching:
		y_velo -= (GRAVITY / WALL_SLIDE_SPEED)
		if y_velo < -MAX_WALL_SLIDE_SPEED:
			y_velo = -MAX_WALL_SLIDE_SPEED
	else:
		y_velo -= GRAVITY
		if y_velo < -MAX_FALL_SPEED:
			y_velo = -MAX_FALL_SPEED
		
			#fall damage
			var collision = move_and_collide(Vector3.DOWN*10, true, true, true)
			if collision != null:
				stamina - collision.travel.length()
				
		if !is_crouching and is_grounded() and y_velo <= 0:
			y_velo = -0.1
	
func p_move():
	var real_acceleration_speed = 0.0
	if is_standing_still or is_crouching:
		if is_grounded():
			speed_rate -= DECELERATION
		else:
			speed_rate -= AIR_DECELERATION	
		real_acceleration_speed = deceleration_curve.interpolate(speed_rate)
	else:
		if is_grounded():
			speed_rate += ACCELERATION
		else:
			speed_rate += AIR_ACCELERATION
		real_acceleration_speed = acceleration_curve.interpolate(speed_rate)
	speed_rate = clamp(speed_rate, 0.0, 1.0)		

	if is_grounded():
		if is_crouching:
			move_vec = facing_vec * (real_acceleration_speed * CROUCH_SPEED_MOD)
		else:
			move_vec = facing_vec * (real_acceleration_speed * SPEED_MOD)			
	elif is_walled():
		move_vec = facing_vec * (real_acceleration_speed * WALL_SPEED_MOD)	
	else:
		move_vec = facing_vec * (real_acceleration_speed * AIR_SPEED_MOD)
		
	var real_move_vec = Vector3(move_vec.x, y_velo, move_vec.z)
	real_move_vec += dash_vec
	real_move_vec += wall_jump_vec
	
	#just zero out snap vector when jumping. and maybe add wall snap vector when wall running
	if is_jumping:
		move_and_slide(real_move_vec, Vector3(0, 1, 0))
	else:
		if is_crouching:
			p_slide(real_move_vec)
#			move_vec = move_and_slide_with_snap(real_move_vec, Vector3(0, -1, 0),Vector3(0, 1, 0), false, 4, deg2rad(80))			
		else:
			move_and_slide_with_snap(real_move_vec, Vector3(0, -1, 0),Vector3(0, 1, 0), true, 4, deg2rad(80), false)
			
func p_slide(real_move_vec: Vector3):
	var collision = move_and_collide(real_move_vec, true, true, true)
	if (collision != null):
		speed_rate += .05
		real_move_vec += collision.remainder
		move_and_slide_with_snap(real_move_vec, collision.normal, Vector3(0, 1, 0), false, 4, deg2rad(80), false)
	
func play_anim(name):
	if anim.current_animation == name:
		return
	anim.play(name)

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

# Air.gd
extends PlayerState


# If we get a message asking us to jump, we jump.
func enter(msg := {}) -> void:
	if msg.has("do_jump"):
		player.y_velo = player.JUMP_FORCE
		player.play_anim("jump")
	elif msg.has("do_air_jump") and player.stamina >= 0:
		player.y_velo = player.AIR_JUMP_FORCE
		player.stamina -= player.AIR_JUMP_STAM_COST
		player.play_anim("jump")


func physics_update(delta: float) -> void:
	# Vertical movement. first to add to movement	
	player.y_velo -= player.GRAVITY
	if player.y_velo < -player.MAX_FALL_SPEED:
		player.y_velo = -player.MAX_FALL_SPEED
	# Horizontal movement.
	var input_vec: Vector3 = player.get_input_vec()
	player.do_facing(input_vec)
	player.do_movement(input_vec, player.AIR_ACCELERATION, player.AIR_SPEED_MOD, Vector3.ZERO, true)

	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {do_air_jump = true})
	# Landing.
	if player.is_grounded():
		if is_equal_approx(input_vec.length(), 0.0):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Run")

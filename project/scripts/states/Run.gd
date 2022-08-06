# Run.gd
extends PlayerState


func physics_update(delta: float) -> void:
	player.play_anim("walk")
	player.do_recover()
	if not player.is_grounded():
		state_machine.transition_to("Air")
		return

	# We move the run-specific input code to the state.
	var input_vec: Vector3 = player.get_input_vec()
	player.do_momentum_move(input_vec, player.MAX_SPEED, player.RUN_SPEED_MOD)
	player.y_velo = -0.1
	
	if Input.is_action_pressed("aim"):
		state_machine.transition_to("Aim")
	elif Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {do_jump = true})
	elif player.stamina > 0 and Input.is_action_just_pressed("dash"):
		state_machine.transition_to("Dash")		
	elif is_equal_approx(input_vec.length(), 0.0):
		state_machine.transition_to("Idle")

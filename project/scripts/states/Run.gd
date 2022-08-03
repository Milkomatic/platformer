# Run.gd
extends PlayerState


func physics_update(delta: float) -> void:
	player.play_anim("walk")
	if not player.is_grounded():
		state_machine.transition_to("Air")
		return

	# We move the run-specific input code to the state.
	# could pass in curve here
	var input_vec: Vector3 = player.get_input_vec()
	player.do_facing(input_vec)
	player.do_movement(input_vec, player.ACCELERATION, player.SPEED_MOD, Vector3.DOWN, true)
	
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {do_jump = true})
	elif is_equal_approx(input_vec.length(), 0.0):
		state_machine.transition_to("Idle")

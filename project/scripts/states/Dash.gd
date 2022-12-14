# Run.gd
extends PlayerState

var dash_cooldown := 0.0

func enter(msg := {}) -> void:
	player.cam.has_input = true
	player.y_velo = 0
	player.move_vec = player.get_input_vec() * player.DASH_FORCE
	player.play_anim("jump")
	dash_cooldown = player.DASH_LENGTH
	player.spend_stamina(player.DASH_STAM_COST)
	
func physics_update(delta: float) -> void:
	# We move the run-specific input code to the state.
	var input_vec: Vector3 = player.get_input_vec()
	player.do_momentum_move(input_vec, player.MAX_SPEED, 0.1)
	dash_cooldown -= 1

	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {do_air_jump = true})
	elif dash_cooldown <= 0:
		if player.is_grounded():
			if is_equal_approx(input_vec.length(), 0.0):
				state_machine.transition_to("Idle")
			else:
				state_machine.transition_to("Run")
		elif player.is_on_wall():
			state_machine.transition_to("WallRun")
		else:
			state_machine.transition_to("Air")


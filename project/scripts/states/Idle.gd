extends PlayerState


func enter(_msg := {}) -> void:
	# Decelerate when entering idle
	player.move_vec = Vector3.ZERO


func physics_update(_delta: float) -> void:
	# If you have platforms that break when standing on them, you need that check for 
	# the character to fall.
	var input_vec = player.get_input_vec()
	player.do_movement(input_vec, player.DECELERATION, player.SPEED_MOD, Vector3.DOWN, false)
	
	if not player.is_grounded():
		state_machine.transition_to("Air")
		return

	if Input.is_action_just_pressed("jump"):
		# As we'll only have one air state for both jump and fall, we use the `msg` dictionary 
		# to tell the next state that we want to jump
		state_machine.transition_to("Air", {do_jump = true})
	elif not is_equal_approx(input_vec.length(), 0.0):
		state_machine.transition_to("Run")

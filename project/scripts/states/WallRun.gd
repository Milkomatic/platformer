extends PlayerState

var wall_normal := Vector3()

func enter(_msg := {}) -> void:
	var test_collision = player.move_and_collide(player.get_input_vec(), true, true, true)
	if (test_collision != null):
		wall_normal = test_collision.normal

func physics_update(_delta: float) -> void:
	# If you have platforms that break when standing on them, you need that check for 
	# the character to fall.
	if player.y_velo <= 0:
		player.y_velo -= player.GRAVITY / player.WALL_SLIDE_SPEED
		if player.y_velo < -player.MAX_WALL_RUN_SLIDE_SPEED:
			player.y_velo = -player.MAX_WALL_RUN_SLIDE_SPEED
	else:
		player.y_velo -= player.GRAVITY
		if player.y_velo < -player.MAX_FALL_SPEED:
			player.y_velo = -player.MAX_FALL_SPEED
	
	var input_vec = player.get_input_vec()
	player.do_momentum_move(input_vec, player.MAX_SPEED, player.WALL_SPEED_MOD, -wall_normal, wall_normal)
	player.spend_stamina(player.WALL_RUN_STAM_DRAIN)
	
	if player.is_hooked():
		state_machine.transition_to("Hook")	
	elif (player.stamina <= 0) or (not Input.is_action_pressed("dash")):
		state_machine.transition_to("Wall")		
	elif not player.is_walled() or Input.is_action_just_pressed("crouch"):
		state_machine.transition_to("Air")
	elif Input.is_action_just_pressed("jump") and player.stamina > 0:
		state_machine.transition_to("Air", {do_wall_jump = true, wall_normal = wall_normal})
	elif player.is_grounded() and not is_equal_approx(input_vec.length(), 0.0):
		state_machine.transition_to("Run")

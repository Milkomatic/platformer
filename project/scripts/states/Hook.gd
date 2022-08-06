extends PlayerState

var wall_normal := Vector3()
var target: Area

func enter(_msg := {}) -> void:
	target = get_owner().hook_box.get_overlapping_areas()[0]
#	var test_collision = player.move_and_collide(player.get_input_vec(), true, true, true)
#	if (test_collision != null):
#		wall_normal = test_collision.normal

func physics_update(_delta: float) -> void:
	
	player.global_translation = target.global_translation
	
#	player.y_velo = 0
	var input_vec = player.get_input_vec()
	player.do_momentum_move(input_vec, 0, player.RUN_SPEED_MOD, -wall_normal, wall_normal)
	player.do_recover()
#

	if Input.is_action_just_pressed("dash") and player.stamina > 0:
		var test_collision = player.move_and_collide(player.get_input_vec(), true, true, true)
		if (test_collision != null):
			state_machine.transition_to("WallRun")
		else:
			state_machine.transition_to("Dash")
	elif Input.is_action_just_pressed("crouch"):
		state_machine.transition_to("Air")
	elif Input.is_action_just_pressed("jump") and player.stamina > 0:
		state_machine.transition_to("Air", {do_wall_jump = true, wall_normal = wall_normal})
	elif player.is_grounded() and not is_equal_approx(input_vec.length(), 0.0):
		state_machine.transition_to("Run")

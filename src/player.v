import math

import transform { Vector3, Rotation }

// 90 radians
const rads90 = math.radians(90)

// Player represents the player.
struct Player {
mut:
	cameras              []&Camera = []&Camera{cap: 3}
	curr_cam             int
	rot                  Rotation
	pos                  Vector3
	run_mult            f32 = 1.3
	sneak_mult          f32 = 0.5
	base_speed  f32 = 3
}

// new_player instantiates a Player with the provided cameras.
fn new_player(cams ...&Camera) Player {
	return Player{
		cameras: cams
	}
}

// toggle_camera sets the current camera to the next Camera in
// the array. Loops back to beginning when the end is reached.
fn (mut player Player) toggle_camera() {
	player.curr_cam = if (player.curr_cam + 1) == player.cameras.len {
		0
	} else {
		player.curr_cam + 1
	}
}

// current_cam returns the current Camera selected.
fn (mut player Player) current_cam() &Camera {
	return player.cameras[player.curr_cam]
}

// on_key_down handles key presses for the Player.
fn (mut player Player) on_key_down(keydown KeyDown, delta f32) {

	mut cam := player.current_cam()

	sneak := if keydown[.left_control] {
		player.sneak_mult
	} else {
		1
	}

	run := if keydown[.left_shift] {
		if sneak == 1 {
			player.run_mult
		} else {
			1
		}
	} else {
		1
	}

	if keydown[.w] {
		cam.pos += cam.eulers.multf32(player.base_speed * sneak * run * delta)
	} else if keydown[.s] {
		cam.pos -= cam.eulers.multf32(player.base_speed * sneak * delta)
	}
	if keydown[.a] {
		cam.pos -= cam.eulers.multf32(player.base_speed * sneak * run * delta)
	} else if keydown[.d] {
		cam.pos += cam.eulers.multf32(player.base_speed * sneak * run * delta)
	}

	player.pos = cam.pos
}

// move moves the Player in the specified direction at a specified distance.
fn (mut cam Camera) move(dir Facing, dist f32) {
	match dir {
		.north {}
		.northeast {}
		.east {}
		.southeast {}
		.south {}
		.southwest {}
		.west {}
		.northwest {}
	}
}

// facing returns which direction the Player is facing.
fn (player Player) facing() Facing {
	y := player.rot.yaw
	return if y > 337.5 {
		.north
	} else if y > 292.5 {
		.northeast
	} else if y > 247.5 {
		.east
	} else if y > 202.5 {
		.southeast
	} else if y > 157.5 {
		.south
	} else if y > 112.5 {
		.southwest
	} else if y > 67.5 {
		.west
	} else if y > 22.5 {
		.northwest
	} else {
		.north
	}
}

// Facing are the available directions the player can face.
enum Facing {
	north
	northeast
	east
	southeast
	south
	southwest
	west
	northwest
}

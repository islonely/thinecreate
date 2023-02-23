import math

import transform { Vector3 }

// 90 radians
const rads90 = math.radians(90)

// Player represents the player.
[heap]
struct Player {
mut:
	cameras              []&Camera = []&Camera{cap: 3}
	curr_cam             int
	rot                  Vector3
	pos                  Vector3
	run_mult            f32 = 1.4
	sneak_mult          f32 = 0.5
	base_speed  		f32 = 0.01
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

// camera returns a reference to the current Camera being used.
fn (mut player Player) camera() &Camera {
	return player.cameras[player.curr_cam]
}

// on_key_down handles key presses for the Player.
fn (mut player Player) on_key_down(keydown KeyDown, delta f32) {
	mut cam := player.camera()

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

	distance := player.base_speed * delta * sneak * run
	if keydown[.w] {
		cam.pos += cam.front.multf32(distance)
	} else if keydown[.s] {
		cam.pos += cam.front.multf32(-distance)
	}
	if keydown[.a] {
		cam.pos -= cam.front.cross(cam.world_up).normalize().multf32(distance)
	} else if keydown[.d] {
		cam.pos += cam.front.cross(cam.world_up).normalize().multf32(distance)
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
	x := player.rot.x
	return if x > 337.5 {
		.north
	} else if x > 292.5 {
		.northeast
	} else if x > 247.5 {
		.east
	} else if x > 202.5 {
		.southeast
	} else if x > 157.5 {
		.south
	} else if x > 112.5 {
		.southwest
	} else if x > 67.5 {
		.west
	} else if x > 22.5 {
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

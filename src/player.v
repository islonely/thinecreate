import src.transform { Vector3 }

// Player represents the player.
@[heap]
struct Player {
mut:
	cameras    []&Camera = []&Camera{cap: 3}
	curr_cam   int
	pos        Vector3 = Vector3{
		y: 60
		z: -2
	}
	run_mult   f32 = 1.4
	sneak_mult f32 = 0.5
	base_speed f32 = 0.01
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
@[direct_array_access]
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

	// TODO: make it so player cannot move vertically.
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

// facing returns which direction the Player is facing.
fn (mut player Player) facing() Facing {
	yaw := player.camera().yaw
	return if yaw > 337.5 {
		.north
	} else if yaw > 292.5 {
		.northeast
	} else if yaw > 247.5 {
		.east
	} else if yaw > 202.5 {
		.southeast
	} else if yaw > 157.5 {
		.south
	} else if yaw > 112.5 {
		.southwest
	} else if yaw > 67.5 {
		.west
	} else if yaw > 22.5 {
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

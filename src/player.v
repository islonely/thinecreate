import math

// 90 radians
const rads90 = math.radians(90)

// Player represents the player.
struct Player {
mut:
	cameras				 []&Camera = []&Camera{cap: 3}
	curr_cam			 int
	rot                  Rotation
	loc                  Location
	run_speed            f32      = 1.3 / 100
	sneak_speed          f32      = 0.3 / 100
	walk_forwards_speed  f32      = 0.9 / 100
	walk_backwards_speed f32      = 0.7 / 100
	strafe_speed         f32      = 0.7 / 100
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
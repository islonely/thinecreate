import math

// 90 radians
const rads90 = math.radians(90)

// Player represents the player.
struct Player {
mut:
	rot                  Rotation
	loc                  Location = Location{
		x: 0
		y: 0
		z: -6
	}
	run_speed            f32      = 1.3 / 100
	sneak_speed          f32      = 0.3 / 100
	walk_forwards_speed  f32      = 0.9 / 100
	walk_backwards_speed f32      = 0.7 / 100
	strafe_speed         f32      = 0.7 / 100
}

// move_forward moves the player in the direction they're facing.
fn (mut player Player) move_forward(distance f32) {
	player.loc.x += distance * f32(math.sin(math.radians(player.rot.yaw)))
	player.loc.z += distance * f32(math.cos(math.radians(player.rot.yaw)))
}

// move_backwards moves the player in the opposite direction they're facing.
fn (mut player Player) move_backwards(distance f32) {
	player.move_forward(-distance)
}

// move_left moves the player horizontally to the left of where they're facing.
fn (mut player Player) move_left(distance f32) {
	player.loc.x -= distance * f32(math.sin(math.radians(player.rot.yaw) - rads90))
	player.loc.z -= distance * f32(math.cos(math.radians(player.rot.yaw) - rads90))
}

// move_right moves the player horizontally to the right of where they're facing.
fn (mut player Player) move_right(distance f32) {
	player.move_left(-distance)
}

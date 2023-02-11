import math

const rads90 = math.radians(90)

struct Player {
mut:
	rot Rotation
	loc Location
	run_speed f32 = 1.3 / 10
	sneak_speed f32 = 0.3 / 10
	walk_forwards_speed f32 = 0.9 / 10
	walk_backwards_speed f32 = 0.7 / 10
	strafe_speed f32 = 0.7 / 10
}

// move_forward moves the player in the direction they're facing.
fn (mut player Player) move_forward(distance f32) {
	player.loc.x -= distance * f32(math.sin(player.rot.yaw))
	player.loc.y += distance * f32(math.cos(player.rot.yaw))
}

// move_backwards moves the player in the opposite direction they're facing.
fn (mut player Player) move_backwards(distance f32) {
	player.loc.x += distance * f32(math.sin(player.rot.yaw))
	player.loc.y -= distance * f32(math.cos(player.rot.yaw))
}

// move_left moves the player horizontally to the left of where they're facing.
fn (mut player Player) move_left(distance f32) {
	player.loc.x -= distance * f32(math.sin(player.rot.yaw - rads90))
	player.loc.y += distance * f32(math.cos(player.rot.yaw - rads90))
}

// move_right moves the player horizontally to the right of where they're facing.
fn (mut player Player) move_right(distance f32) {
	player.loc.x += distance * f32(math.sin(player.rot.yaw - rads90))
	player.loc.y -= distance * f32(math.cos(player.rot.yaw - rads90))
}
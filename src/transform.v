import math

struct Vertex {
__global:
	x f32
	y f32
	z f32
}

fn (mut v Vertex) rotate(rot Rotation) {
	pitch_cos := math.cos(rot.pitch)
	pitch_sin := math.sin(rot.pitch)
	yaw_cos := math.cos(rot.yaw)
	yaw_sin := math.sin(rot.yaw)
	roll_cos := math.cos(rot.roll)
	roll_sin := math.sin(rot.roll)

	v.y = f32(pitch_cos * v.y - pitch_sin * v.z)
	v.z = f32(pitch_sin * v.y + pitch_cos * v.z)
	v.x = f32(yaw_cos * v.x + yaw_sin * v.z)
	v.z = f32(-yaw_sin * v.x + yaw_cos * v.z)
	v.x = f32(roll_cos * v.x - roll_sin * v.y)
	v.y = f32(roll_sin * v.x + roll_cos * v.y)
}

struct Vector {
__global:
	x f32
	y f32
}

type Location = Vertex

struct Rotation {
__global:
	pitch f32
	yaw f32
	roll f32
}

struct Scale {
__global:
	x f32
	y f32
	z f32
}
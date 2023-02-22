import math { cos, radians, sin }
import sokol.sgl
import time

import transform { Vector3, Rotation }

// Camera the lens you look through to see the 3D space.
struct Camera {
pub mut:
	pos Vector3 = Vector3{
		z: -2
	}
	eulers Vector3

	world_up Vector3 = Vector3{
		z: 1
	}
	front Vector3
	right Vector3
	up    Vector3

	width  int
	height int

	fov        f32 = 90.0
	near_plane f32 = 0.1
	far_plane  f32 = 1000.0

	mouse_sensitivity f32 = 0.01
}

// new instantiates a Camera and returns it.
fn new_camera(width int, height int, pos Vector3) &Camera {
	return &Camera{
		width: width
		height: height
		pos: pos
	}
}

// aspect_ratio calculates the aspect ratio of the Camera
// and returns it.
fn (cam Camera) aspect_ratio() f32 {
	return f32(width) / f32(height)
}

// sgl changes the position of the Camerea relative to
// location, orientation, and up.
fn (mut cam Camera) sgl() {
	sgl.matrix_mode_projection()
	sgl.perspective(sgl.rad(cam.fov), cam.aspect_ratio(), cam.near_plane, cam.far_plane)

	// vfmt off
	// alpha := sin(radians(cam.eulers.y))
	// cam.front = Vector3{
	// 	x: f32(alpha * cos(radians(cam.eulers.z)))
	// 	y: f32(alpha * sin(radians(cam.eulers.z)))
	// 	z: f32(cos(radians(cam.eulers.y)))
	// }
	// cam.right = cam.front.cross(cam.world_up)
	// cam.up = cam.right.cross(cam.front)
	// center := cam.pos + cam.front
	// sgl.lookat(
	// 	cam.pos.x, cam.pos.x, cam.pos.y,
	// 	center.x, center.y, center.z,
	// 	cam.up.x, cam.up.y, cam.up.z
	// )
	// vfmt on

	sgl.translate(cam.pos.x, cam.pos.y, cam.pos.z)
	sgl.rotate(f32(radians(cam.eulers.x)), 0, 1, 0)
	sgl.rotate(f32(radians(cam.eulers.y)), 1, 0, 0)
}

// on_mouse_move changes euler angles of the camera relative to mouse movement.
fn (mut cam Camera) on_mouse_move(mut game Game) {
	rotx := cam.mouse_sensitivity * f32(game.delta_time) * game.g.mouse_dx
	roty := cam.mouse_sensitivity * f32(game.delta_time) * game.g.mouse_dy

	cam.eulers += Vector3{
		x: if (cam.eulers.x + rotx) > 180 {
			rotx - 360
		} else if (cam.eulers.x + rotx) < -180 {
			rotx + 360
		} else {
			rotx
		}
		y: roty
	}

	println('X: ${cam.eulers.x} degrees')
	println('Y: ${cam.eulers.y} degrees')
}
import math { cos, radians, sin }
import sokol.sgl

import transform { Vector3, Rotation }

// Camera the lens you look through to see the 3D space.
struct Camera {
pub mut:
	pos Vector3 = Vector3{
		z: -2
	}
	rot Rotation

	world_up Vector3 = Vector3{
		y: 1
	}
	front Vector3
	right Vector3
	up    Vector3

	width  int
	height int

	fov        f32 = 90.0
	near_plane f32 = 0.1
	far_plane  f32 = 1000.0

	mouse_sensitivity f32 = 0.5
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
	cos_pitch := cos(radians(cam.rot.pitch))
	cam.front = Vector3{
		x: f32(cos(radians(cam.rot.yaw)) * cos_pitch)
		y: f32(sin(radians(cam.rot.pitch)))
		z: f32(sin(radians(cam.rot.yaw)) * cos_pitch)
	}
	cam.front = cam.front.normalize()
	cam.right = cam.front.cross(cam.world_up).normalize()
	cam.up = cam.right.cross(cam.front).normalize()
	center := cam.pos + cam.front
	
	sgl.lookat(
		cam.pos.x, cam.pos.x, cam.pos.y,
		center.x, center.y, center.z,
		cam.up.x, cam.up.y, cam.up.z
	)
	// vfmt on

	sgl.translate(cam.pos.x, cam.pos.y, cam.pos.z)
}

fn (mut cam Camera) on_mouse_move(dirx f32, diry f32, invert_y int, delta f32) {
	cam.rot.pitch += diry * cam.mouse_sensitivity * delta * invert_y
	yaw := dirx * cam.mouse_sensitivity * delta

	cam.rot.pitch = if cam.rot.pitch >= 90.0 {
		f32(90.0)
	} else if cam.rot.pitch <= -90.0 {
		-90.0
	} else {
		0
	}

	cam.rot.yaw += if (cam.rot.yaw + yaw) > 360 {
		-360 + yaw
	} else if (cam.rot.yaw + yaw) < -360 {
		360 + yaw
	} else {
		yaw
	}
}
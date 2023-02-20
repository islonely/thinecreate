import math
import sokol.sgl

// Camera the lens you look through to see the 3D space.
struct Camera {
pub:
	up  Vector3 = Vector3{y: 1}
pub mut:
	loc Location = Location{z: -2}
	rot Rotation

	width  int
	height int

	fov        f32 = 90.0 // mesured in degrees
	near_plane f32 = 0.1
	far_plane  f32 = 100.0

	speed             f32 = 0.1
}

// new instantiates a Camera and returns it.
fn new_camera(width int, height int, loc Location) &Camera {
	return &Camera{
		width: width
		height: height
		loc: loc
	}
}

// aspect_ratio calculates the aspect ratio of the Camera
// and returns it.
fn (cam Camera) aspect_ratio() f32 {
	return f32(width) / f32(height)
}

// sgl changes the position of the Camerea relative to
// location, orientation, and up.
fn (cam Camera) sgl() {
	sgl.matrix_mode_projection()
	sgl.perspective(sgl.rad(cam.fov), cam.aspect_ratio(), cam.near_plane, cam.far_plane)
	// vfmt off
	sgl.lookat(
		cam.loc.x, cam.loc.x, cam.loc.y,
		(cam.loc.x + cam.rot.yaw), (cam.loc.y + cam.rot.pitch), (cam.loc.z + cam.rot.roll),
		cam.up.x, cam.up.y, cam.up.z
	)
	// vfmt on 
	sgl.translate(cam.loc.x, cam.loc.y, cam.loc.z)
}
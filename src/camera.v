import math { cos, radians, sin }
import sokol.sgl
import src.transform { Vector3 }

// Camera the lens you look through to see the 3D space.
@[heap]
struct Camera {
pub mut:
	world_up Vector3 = Vector3{
		y: 1
	}
	pos      Vector3
	front    Vector3

	yaw   f32 = -90
	pitch f32

	width      int
	height     int
	fov        f32 = 90.0
	near_plane f32 = 0.1
	far_plane  f32 = 100.0

	parent &Player
}

// new_camera instantiates a Camera and returns it.
@[inline]
fn new_camera(parent &Player, width int, height int, fov f32) &Camera {
	return &Camera{
		parent: parent
		width:  width
		height: height
		fov:    fov
		pos:    parent.pos
	}
}

// aspect_ratio calculates the aspect ratio of the Camera and returns it.
@[inline]
fn (cam Camera) aspect_ratio() f32 {
	return f32(width) / f32(height)
}

// on_mouse_move changes euler angles of the camera relative to mouse movement.
fn (mut cam Camera) on_mouse_move() {
	cos_pitch := cos(radians(cam.pitch))
	cam.front = Vector3{
		x: f32(cos(radians(cam.yaw)) * cos_pitch)
		y: f32(sin(radians(cam.pitch)))
		z: f32(sin(radians(cam.yaw)) * cos_pitch)
	}
	cam.front = cam.front.normalize()
}

// perspective sets the sgl matrix perspective.
@[inline]
fn (cam Camera) perspective() {
	sgl.perspective(sgl.rad(cam.fov), cam.aspect_ratio(), cam.near_plane, cam.far_plane)
}

// update updates where the Camerea is currently looking at.
fn (mut cam Camera) update() {
	cam.perspective()
	center := cam.pos + cam.front
	// vmft off
	sgl.lookat(cam.pos.x, cam.pos.y, cam.pos.z, center.x, center.y, center.z, cam.world_up.x,
		cam.world_up.y, cam.world_up.z)
	// vfmt on
}

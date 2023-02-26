import gg
import sokol.sgl

// sgl_draw_cube draws a cube to the scren using the sokol.sgl module.
fn sgl_draw_cube(size f32) {
	// vfmt off
	sgl.begin_quads()
	{
		// 			  X      Y      Z        U     V
		// back face
		sgl.v3f_t2f(-size,  size, -size,	1.0,  0.33333334)
		sgl.v3f_t2f( size,  size, -size,	0.75, 0.33333334)
		sgl.v3f_t2f( size, -size, -size,	0.75, 0.66666667)
		sgl.v3f_t2f(-size, -size, -size,	1.0,  0.66666667)
		// front face
		sgl.v3f_t2f(-size, -size, size,		0.25, 0.66666667)
		sgl.v3f_t2f( size, -size, size,		0.5,  0.66666667)
		sgl.v3f_t2f( size,  size, size,		0.5,  0.33333334)
		sgl.v3f_t2f(-size,  size, size,		0.25, 0.33333334)
		// left face
		sgl.v3f_t2f(-size,  size,  size,	0.25, 0.33333334)
		sgl.v3f_t2f(-size,  size, -size,	0.0,  0.33333334)
		sgl.v3f_t2f(-size, -size, -size,	0.0,  0.66666667)
		sgl.v3f_t2f(-size, -size,  size,	0.25, 0.66666667)
		// right face
		sgl.v3f_t2f(size, -size,  size,		0.5,  0.66666667)
		sgl.v3f_t2f(size, -size, -size,		0.75, 0.66666667)
		sgl.v3f_t2f(size,  size, -size,		0.75, 0.33333334)
		sgl.v3f_t2f(size,  size,  size,		0.5,  0.33333334)
		// bottom face
		sgl.v3f_t2f( size, -size, -size,	0.5,  1.0)
		sgl.v3f_t2f( size, -size,  size,	0.5,  0.66666667)
		sgl.v3f_t2f(-size, -size,  size,	0.25, 0.66666667)
		sgl.v3f_t2f(-size, -size, -size,	0.25, 1.0)
		// top face
		sgl.v3f_t2f(-size, size, -size,		0.25, 0.0)
		sgl.v3f_t2f(-size, size,  size,		0.25, 0.33333334)
		sgl.v3f_t2f( size, size,  size,		0.5,  0.33333334)
		sgl.v3f_t2f( size, size, -size,		0.5,  0.0)
	}
	// vfmt on
}

// dpi_scale returns the appropriate scale for Android.
[inline]
fn dpi_scale(mut game Game) f32 {
	return $if android {
		game.g.scale
	} $else {
		gg.dpi_scale()
	}
}

// window_size returns the appropriate size for Android.
[inline]
fn window_size(mut game Game) gg.Size {
	return $if android {
		game.g.window_size()
	} $else {
		gg.window_size()
	}
}

// real_window_size returns the real appropriate size for Android.
[inline]
fn real_window_size(mut game Game) gg.Size {
	return $if android {
		game.g.window_size()
	} $else {
		gg.window_size_real_pixels()
	}
}
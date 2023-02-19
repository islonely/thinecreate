import sokol.sgl
import sokol.gfx

fn bufferedimage_to_gfximage(buf_img &BufferedImage, filter gfx.Filter) gfx.Image {
	size := buf_img.width * buf_img.height * 4
	mut gfx_img_desc := gfx.ImageDesc{
		width: buf_img.width
		height: buf_img.height
		num_mipmaps: 0
		min_filter: filter
		mag_filter: filter
		wrap_u: .clamp_to_edge
		wrap_v: .clamp_to_edge
		label: &u8(0)
		d3d11_texture: 0
	}
	gfx_img_desc.data.subimage[0][0] = gfx.Range{
		ptr: buf_img.buffer
		size: usize(size)
	}
	return gfx.make_image(&gfx_img_desc)
}

fn sgl_draw_cube(size int) {
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
	sgl.end()
	// vfmt on
}
import sokol.sgl
import sokol.gfx

const block_size = 16

const half_block_size = block_size / 2

// Block represents a block in the game.
struct Block {
pub:
	id      int
	name    string
	texture &BufferedImage = unsafe { nil }
mut:
	gfx_texture gfx.Image
pub mut:
	loc Location
}

// new_block instantiates a `Block`.
fn new_block(id int, name string, texture &BufferedImage, loc Location) &Block {
	mut block := &Block{
		id: id
		name: name
		texture: texture
		loc: loc
	}
	sz := texture.width * texture.height * 4
	mut img_desc := gfx.ImageDesc{
		width: texture.width
		height: texture.height
		num_mipmaps: 0
		min_filter: .nearest
		mag_filter: .nearest
		wrap_u: .clamp_to_edge
		wrap_v: .clamp_to_edge
		label: &u8(0)
		d3d11_texture: 0
	}
	img_desc.data.subimage[0][0] = gfx.Range{
		ptr: block.texture.buffer
		size: usize(sz)
	}
	block.gfx_texture = gfx.make_image(&img_desc)
	return block
}

// draw renders the block to the screen
fn (mut block Block) draw(mut game Game) {
	sgl.defaults()
	sgl.load_pipeline(game.pipeline)

	sgl.enable_texture()
	sgl.texture(block.gfx_texture)

	sgl.matrix_mode_projection()
	sgl.perspective(sgl.rad(game.fov), game.aspect_ratio, 0.1, 1000.0)
	sgl.rotate(sgl.rad(-game.player.rot.yaw), 0.0, 1.0, 0.0)
	sgl.rotate(sgl.rad(-game.player.rot.pitch), 1.0, 0.0, 0.0)
	sgl.rotate(sgl.rad(-game.player.rot.roll), 0.0, 0.0, 1.0)
	x := game.player.loc.x
	y := game.player.loc.y
	z := game.player.loc.z
	sgl.translate(x, y, z)

	// vfmt off
	sgl.matrix_mode_modelview()
	sgl.begin_quads()
	{
		sgl.push_matrix()
		{
			// 			  X     Y     Z      U     V
			// back face
			sgl.v3f_t2f(-1.0,  1.0, -1.0,	1.0,  0.33333)
			sgl.v3f_t2f( 1.0,  1.0, -1.0,	0.75, 0.33333)
			sgl.v3f_t2f( 1.0, -1.0, -1.0,	0.75, 0.66666)
			sgl.v3f_t2f(-1.0, -1.0, -1.0,	1.0,  0.66666)
			// front face
			sgl.v3f_t2f(-1.0, -1.0, 1.0,	0.25, 0.66666)
			sgl.v3f_t2f( 1.0, -1.0, 1.0,	0.5,  0.66666)
			sgl.v3f_t2f( 1.0,  1.0, 1.0,	0.5,  0.33333)
			sgl.v3f_t2f(-1.0,  1.0, 1.0,	0.25, 0.33333)
			// left face
			sgl.v3f_t2f(-1.0,  1.0,  1.0,	0.25, 0.33333)
			sgl.v3f_t2f(-1.0,  1.0, -1.0,	0.0,  0.33333)
			sgl.v3f_t2f(-1.0, -1.0, -1.0,	0.0,  0.66666)
			sgl.v3f_t2f(-1.0, -1.0,  1.0,	0.25, 0.666)
			// right face
			sgl.v3f_t2f(1.0, -1.0,  1.0,	0.5,  0.66666)
			sgl.v3f_t2f(1.0, -1.0, -1.0,	0.75, 0.66666)
			sgl.v3f_t2f(1.0,  1.0, -1.0,	0.75, 0.33333)
			sgl.v3f_t2f(1.0,  1.0,  1.0,	0.5,  0.33333)
			// bottom face
			sgl.v3f_t2f( 1.0, -1.0, -1.0,	0.5,  1.0)
			sgl.v3f_t2f( 1.0, -1.0,  1.0,	0.5,  0.66666)
			sgl.v3f_t2f(-1.0, -1.0,  1.0,	0.25, 0.66666)
			sgl.v3f_t2f(-1.0, -1.0, -1.0,	0.25, 1.0)
			// top face
			sgl.v3f_t2f(-1.0, 1.0, -1.0,	0.25, 0.0)
			sgl.v3f_t2f(-1.0, 1.0,  1.0,	0.25, 0.33333)
			sgl.v3f_t2f( 1.0, 1.0,  1.0,	0.5,  0.33333)
			sgl.v3f_t2f( 1.0, 1.0, -1.0,	0.5,  0.0)
		}
	}
	sgl.end()
	// vfmt on

	sgl.pop_matrix()
	sgl.disable_texture()
}

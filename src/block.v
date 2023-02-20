import sokol.sgl
import sokol.gfx

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
	block.gfx_texture = bufferedimage_to_gfximage(block.texture, .nearest)
	return block
}

// draw renders the block to the screen
fn (mut block Block) draw(mut game Game) {
	sgl.defaults()
	sgl.load_pipeline(game.pipeline)
	sgl.enable_texture()
	sgl.texture(block.gfx_texture)
	sgl.push_matrix()
	game.player.cameras[game.player.curr_cam].sgl()
	sgl.matrix_mode_modelview()
	sgl_draw_cube(1)
	sgl.pop_matrix()
	sgl.disable_texture()
}

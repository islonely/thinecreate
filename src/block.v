import sokol.sgl
import sokol.gfx

import bufferedimage as buffered
import transform { Vector3 }

// Block represents a block in the game.
struct Block {
pub:
	id      int
	name    string
	texture &buffered.Image = unsafe { nil }
mut:
	gfx_texture gfx.Image
pub mut:
	pos Vector3
}

// new_block instantiates a `Block`.
fn new_block(id int, name string, texture &buffered.Image, pos Vector3) &Block {
	mut block := &Block{
		id: id
		name: name
		texture: texture
		pos: pos
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
	mut cam := game.player.current_cam()
	cam.sgl()
	sgl.matrix_mode_modelview()
	sgl_draw_cube(1)
	sgl.pop_matrix()
	sgl.disable_texture()
}

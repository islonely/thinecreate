import sokol.sgl

import transform { Vector3 }

// Block represents a block in the game.
struct Block {
pub:
	typ  BlockType = .test
	name string
pub mut:
	pos Vector3
}

// new_block instantiates a `Block`.
fn new_block(typ BlockType, name string, pos Vector3) &Block {
	mut block := &Block{
		typ: typ
		name: name
		pos: pos
	}
	return block
}

// draw renders the block to the screen
fn (mut block Block) draw(mut game Game) {
	sgl.defaults()
	sgl.load_pipeline(game.pipeline)

	sgl.enable_texture()
	sgl.texture(game.textures['blocks'][int(block.typ)])
	sgl.push_matrix()

	sgl.matrix_mode_projection()
	mut cam := game.camera()
	cam.update()

	sgl.matrix_mode_modelview()
	sgl_draw_cube(1)
	sgl.translate(block.pos.x, block.pos.y, block.pos.z)
	sgl.end()

	sgl.pop_matrix()
	sgl.disable_texture()
}

enum BlockType as int {
	test = 0
	grass
}
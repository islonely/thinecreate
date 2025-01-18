import src.transform { Vector3 }

// IMPORTANT NOTE: When more than 1811 blocks are drawn by a Chunk the entire screen turns
// black. This is probably the most important thing to figure out. A voxel engine that can
// only render 1811 blocks is not very fun. Also note that this value 1811 isn't fixed.
// Whenever I add an additional gg.Context.draw_text somewhere in the code it reduces the
// value even more. I've honestly got no idea what would cause this. This is the first 3D
// programming I've ever done.
const max_height = 128

const chunk_size = 16

// Chunk is an area of X by X by max_height containing information about all the
// Blocks in the area.
struct Chunk {
	pos Vector3
mut:
	size   int = chunk_size
	height int = max_height
	blocks [][][]&Block
}

// new_chunk creates a Chunk with the specified size.
@[direct_array_access]
fn new_chunk(size int, p Vector3) &Chunk {
	mut chunk := &Chunk{
		size: size
		pos:  p
	}

	mut area := [][]&Block{}
	mut row := []&Block{cap: chunk.height}
	for y in 0 .. chunk.height {
		area = [][]&Block{}
		for x in 0 .. chunk.size {
			row = []&Block{cap: chunk.height}
			for z in 0 .. chunk.size {
				pos := Vector3{x, y, z} + chunk.pos
				row << if y > 60 {
					new_block(.juniper, 'block_juniper', pos, suffocates: true)
				} else if y > 59 {
					new_block(.grass, 'block_grass', pos, BlockProperties{})
				} else if y > 50 {
					new_block(.dirt, 'block_dirt', pos, BlockProperties{})
				} else if y >= 0 {
					new_block(.stone, 'block_stone', pos, BlockProperties{})
				} else {
					new_air_block(pos)
				}
			}
			area << row
		}
		chunk.blocks << area
	}

	return chunk
}

// draw draws each Block in the chunk to the screen
@[direct_array_access]
fn (mut chunk Chunk) draw(mut game Game) {
	for x in 0 .. chunk.size {
		for y in 0 .. chunk.size {
			for z in 0 .. chunk.height {
				chunk.blocks[z][x][y].draw(mut game)
			}
		}
	}
}

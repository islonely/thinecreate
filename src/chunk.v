const max_height = 256
const chunk_size = 16

struct Chunk {
mut:
	size int = chunk_size
	blocks [][]&Block = [][]&Block{len: chunk_size, init: []&Block{cap: chunk_size * max_height}}
}

fn new_chunk(size int) &Chunk {
	mut chunk := &Chunk{
		size: size
		blocks: [][]&Block{len: size, init: []&Block{cap: size * max_height}}
	}

	for x in 0..chunk.size {
		for y in 0..chunk.size {
			println('before')
			chunk.blocks[x][y] = new_block(.grass, 'block_grass', x: x, y: y)
			println('after')
		}
	}

	return chunk
}

fn (mut chunk Chunk) draw(mut game Game) {
	for x in 0..chunk.size {
		for y in 0..chunk.size {
			chunk.blocks[x][y].draw(mut game)
		}
	}
}
module textures

import bufferedimage as bimg

pub const (
	block_grass = bimg.new_from_bytes_or_exit($embed_file('src/img/block_grass.png').to_bytes())
	block_test  = bimg.new_from_bytes_or_exit($embed_file('src/img/block_test.png').to_bytes())

	misc_skybox = bimg.new_from_bytes_or_exit($embed_file('src/img/skybox.png').to_bytes())
)
import gg
import stbi

struct Texture {
	gg.Image
	pixels &int = unsafe { nil }
}

fn texture_from_memory(buf &u8, size int) !&Texture {
	stb_img := stbi.load_from_memory(buf, size)!
	mut img := gg.Image{
		width: stb_img.width
		height: stb_img.height
		nr_channels: stb_img.nr_channels
		ok: stb_img.ok
		data: stb_img.data
		ext: stb_img.ext
	}
	mut texture := &Texture{
		Image: img
		pixels: stb_img.data
	}
	return texture
}

fn texture_from_bytes(bytes []u8) !&Texture {
	return texture_from_memory(bytes.data, bytes.len)!
}

fn init_textures(mut game Game) ! {
	game.textures << texture_from_bytes($embed_file('./img/block_grass_bottom.png').to_bytes())!
	game.textures << texture_from_bytes($embed_file('./img/block_grass_side.png').to_bytes())!
	game.textures << texture_from_bytes($embed_file('./img/block_grass_top.png').to_bytes())!
}
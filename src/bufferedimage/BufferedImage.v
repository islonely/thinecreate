module bufferedimage

import gx
import math
import stbi

// Image is exactly what it says it is.
[heap]
pub struct Image {
pub mut:
	buffer &int = unsafe { nil }
	width  int
	height int
	channels int = 4
}

// size returns the buffer size of the image
[inline]
pub fn (img Image) size() int {
	return img.width * img.height * img.channels
}
// new instantiates a `Image` from a provided
// width and height and allocates memory for the image data.
pub fn new(width int, height int) &Image {
	if width < 0 || height < 0 {
		return 0
	}
	mut img := &Image{
		width: width
		height: height
	}
	unsafe {
		img.buffer = malloc(img.width * img.height * img.channels)
	}
	return img
}

pub fn new_from_memory(b &u8, size int) !&Image {
	stb_img := stbi.load_from_memory(b, size)!
	mut img := &Image{
		width: stb_img.width
		height: stb_img.height
		buffer: stb_img.data
	}
	return img
}

// new_from_bytes instantiates a Image
// from the provided byte array.
[inline]
pub fn new_from_bytes(b []u8) !&Image {
	return new_from_memory(b.data, b.len)!
}

// new_from_bytes_or_exit instantiates a Image
// from the provided byte array or prints an error and exits.
[inline]
pub fn new_from_bytes_or_exit(b []u8) &Image {
	return new_from_bytes(b) or {
		println('Failed to load texture.\nExiting...')
		println(err.msg())
		exit(0)
	}
}

// zero sets the image data to 0s by reallocating the memory.
// NOTE: I'm not sure if this is the optimal way to do this :|
[inline]
pub fn (mut img Image) zero() {
	unsafe {
		img.buffer = malloc(img.width * img.height * 4)
	}
}

// fill sets all of the image data to one color
pub fn (mut img Image) fill(val int) {
	for i in 0 .. (img.width * img.height * 1) {
		unsafe {
			img.buffer[i] = val
		}
	}
}

// draw_pixel draws a pixel to the image data at (x, y).
pub fn (mut img Image) draw_pixel(x int, y int, color gx.Color) {
	if (x < 0 || y < 0) || (x > img.width || y > img.width) {
		return
	}
	unsafe {
		img.buffer[x + y * img.width] = color.abgr8()
	}
}

// draw_pixel_int draws a pixel to the image data at (x, y)
// with color in the format of an integer.
pub fn (mut img Image) draw_pixel_int(x int, y int, color int) {
	if (x < 0 || y < 0) || (x > img.width || y > img.width) {
		return
	}
	unsafe {
		img.buffer[x + y * img.width] = color
	}
}

// draw_line draws a line to the image data from (x0, y0) to (x1, y1).
pub fn (mut img Image) draw_line(x0 int, y0 int, x1 int, y1 int, color gx.Color) {
	mut x := x0
	mut y := y0
	mut dx := x1 - x0
	mut dy := y1 - y0
	mut sx := int(math.sign(dx))
	mut sy := int(math.sign(dy))
	dx = int(math.abs(dx))
	dy = int(math.abs(dy))

	mut interchange := false
	if dy > dx {
		tmp := dx
		dx = dy
		dy = tmp
		interchange = true
	}

	mut error := 2 * dy - dx

	for _ in 0 .. dx {
		img.draw_pixel(x, y, color)
		for error > 0 {
			if interchange {
				x += sx
			} else {
				y += sy
			}
			error -= 2 * dx
		}
		if interchange {
			y += sy
		} else {
			x += sx
		}
		error += 2 * dy
	}
}

// draw_triangle draws an empty triangle to the image data.
[inline]
pub fn (mut img Image) draw_triangle(x0 int, y0 int, x1 int, y1 int, x2 int, y2 int, color gx.Color) {
	img.draw_line(x0, y0, x1, y1, color)
	img.draw_line(x1, y1, x2, y2, color)
	img.draw_line(x2, y2, x0, y0, color)
}

// draw_rectangle draws an empty rectangle to the image data.
[inline]
pub fn (mut img Image) draw_rectangle(x0 int, y0 int, x1 int, y1 int, color gx.Color) {
	img.draw_line(x0, y0, x1, y0, color)
	img.draw_line(x1, y0, x1, y1, color)
	img.draw_line(x1, y1, x0, y1, color)
	img.draw_line(x0, y1, x0, y0, color)
}

// draw_square draws an empty square to the image data.
[inline]
pub fn (mut img Image) draw_square(x int, y int, size int, color gx.Color) {
	img.draw_rectangle(x, y, size, size, color)
}

// draw_filled_rectangle draws a filled rectangle to the image data.
[inline]
pub fn (mut img Image) draw_filled_rectangle(x0 int, y0 int, x1 int, y1 int, color gx.Color) {
	for x in x0 .. x1 {
		img.draw_line(x, y0, x, y1, color)
	}
}

// draw_filled_square draws a filled square to the image data.
[inline]
pub fn (mut img Image) draw_filled_square(x int, y int, size int, color gx.Color) {
	img.draw_filled_rectangle(x, y, x + size, y + size, color)
}
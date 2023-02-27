import gg
import gx

// SettingsMenu
struct SettingsMenu {
	Menu
}

// Settings is the Game settings
struct Settings {
mut:
	menu SettingsMenu

	debug bool

	mouse_sensitivity f32 = 0.5
	invert_y_axis     int = -1 // -1 = false, 1 = true

	fov f32 = 90.0

	fullscreen bool
	resolution gg.Size = gg.Size{width, height}
}

// draw
fn (mut settings Settings) draw(mut game Game) {
	game.g.draw_image(0, 0, (game.width / dpi_scale(mut game)), (game.height / dpi_scale(mut game)),
		game.menu_background)
	game.g.draw_rect_filled(0, 0, (game.width / dpi_scale(mut game)), (game.height / dpi_scale(mut game)), gx.hex(0x111111c0))
	settings.menu.draw(mut game)
}
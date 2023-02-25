import gg
import gx
import math { sin }

// MainMenu
struct MainMenu {
mut:
	x int
	y int
	text_size int = 44
	text_shadow bool = true
	padding int = 15
	step bool = true
	step_size int = 35
	step_dir StepDirection = .left
	selected int
	items []MenuItem
}

// MenuItem represents an individual item in the MainMenu.
struct MenuItem {
	on_selected fn()
	label string = '<label_not_set>'
	text_color gx.Color = gx.hex(0x151515ff)
}

// StepDirection
enum StepDirection {
	left
	right
}

// update updates the menu.
fn (mut menu MainMenu) update(keydown KeyDown, mut game Game) {
	if keydown[.enter] {
		menu.items[menu.selected].on_selected()
		return
	}

	if keydown[.up] {
		if menu.selected == 0 {
			menu.selected = menu.items.len-1
		} else {
			menu.selected--
		}
		game.key_is_down[.up] = false
	} else if keydown[.down] {
		if menu.selected == menu.items.len-1 {
			menu.selected = 0
		} else {
			menu.selected++
		}
		game.key_is_down[.down] = false
	}
}

// draw draws the MainMenu to the screen.
fn (menu MainMenu) draw(mut game Game) {
	game.g.draw_image(0, 0, (game.width/gg.dpi_scale()), (game.height/gg.dpi_scale()), game.menu_background)
	logo_scale := f32(0.33)
	logo_scaled_width := f32(game.logo.width) * logo_scale
	logo_scaled_height := f32(game.logo.height) * logo_scale
	logo_x := game.width/gg.dpi_scale()/2 - logo_scaled_width/2
	game.g.draw_image(logo_x, 50, logo_scaled_width, logo_scaled_height, game.logo)
	for i, item in menu.items {
		step := (i * menu.step_size)
		x := if menu.step {
			menu.x + if menu.step_dir == .right {
				step
			} else {
				-step
			}
		} else {
			menu.x
		}
		y := menu.y + (i * menu.text_size + menu.padding)
		game.g.draw_text(x, y, item.label,
			size: menu.text_size
			vertical_align: .middle
			align: if menu.step_dir == .right {
				.right
			} else {
				.left
			}
			mono: true
			color: if i == menu.selected {
				gx.white
			} else {
				item.text_color
			}
		)
	}
}
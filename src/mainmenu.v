import gx
import src.transform { Vector2 }

// MainMenu
struct MainMenu {
	Menu
}

// Menu
[heap]
struct Menu {
mut:
	pos         Vector2
	text_size   int           = 44
	text_shadow bool          = true
	text_color  gx.Color      = gx.white
	disabled_color gx.Color = gx.hex(0xbceaff9f)
	padding     int           = 8
	bold		bool
	italic		bool		  = true
	monospaced	bool
	step        bool          = true
	step_size   int           = 35
	step_dir    StepDirection = .left

	selector_pos      Vector2
	selector_target   Vector2
	selector_velocity Vector2
	selector_speed    f32 = 1 // lower value = faster speed
	selected          int
	selected_color    gx.Color = gx.hex(0xff2c80ff)
	items             []MenuItem
}

// MenuItem represents an individual item in the MainMenu.
struct MenuItem {
mut:
	on_selected fn () = fn(){}
	label       string = '<label_not_set>'
	disabled	bool
	clickable   bool = true
}

// StepDirection is the directions the list items can be
// stepped downwards.
enum StepDirection {
	left
	right
}

// update handles key presses on the Menu among other things.
fn (mut menu Menu) update(keydown KeyDown, mut game Game) {
	if keydown[.enter] {
		item := menu.items[menu.selected]
		if !item.clickable {
			return
		}
		item.on_selected()
		game.key_is_down[.enter] = false
		return
	}

	if keydown[.up] {
		if menu.selected == 0 {
			menu.selected = menu.items.len - 1
		} else {
			menu.selected--
		}
		game.key_is_down[.up] = false
	} else if keydown[.down] {
		if menu.selected == menu.items.len - 1 {
			menu.selected = 0
		} else {
			menu.selected++
		}
		game.key_is_down[.down] = false
	}

	if menu.selector_pos < menu.selector_target {
		menu.selector_pos += menu.selector_velocity
	}
}

// draw draws the MainMenu to the screen.
fn (mut menu MainMenu) draw(mut game Game) {
	game.g.draw_image(0, 0, (game.width / dpi_scale(mut game)), (game.height / dpi_scale(mut game)),
		game.menu_background)
	menu.Menu.draw(mut game)

	logo_scale := f32(0.33)
	logo_scaled_width := f32(game.logo.width) * logo_scale
	logo_scaled_height := f32(game.logo.height) * logo_scale
	logo_x := game.width / dpi_scale(mut game) / 2 - logo_scaled_width / 2
	game.g.draw_image(logo_x, 100, logo_scaled_width, logo_scaled_height, game.logo)
}

// draw draws the Menu to the screen.
fn (mut menu Menu) draw(mut game Game) {
	for i := 0; i < menu.items.len; i++ {
		item := menu.items[i]
		step := (i * menu.step_size)
		x := if menu.step {
			menu.pos.x + if menu.step_dir == .right {
				step
			} else {
				-step
			}
		} else {
			menu.pos.x
		}
		y := menu.pos.y + (i * menu.text_size + i * menu.padding)

		mut color := if item.disabled {
			menu.disabled_color
		} else {
			menu.text_color
		}
		if i == menu.selected {
			w, h := game.g.text_size(item.label)
			menu.selector_target = Vector2{x, (y + h / 2 + 5)}
			menu.selector_velocity = Vector2{(menu.selector_target.x - menu.selector_pos.x) / f32(game.delta_time), (menu.selector_target.y - menu.selector_pos.y) / f32(game.delta_time)} / Vector2{menu.selector_speed, menu.selector_speed}
			if !item.disabled {
				color = menu.selected_color
				game.g.draw_rounded_rect_filled(menu.selector_pos.x, menu.selector_pos.y,
					w, 2.5, 500, color)
			} else if item.disabled {
				game.g.draw_rounded_rect_filled(menu.selector_pos.x, menu.selector_pos.y-f32(h)/1.5,
					w, 2.5, 500, color)
			}
		}

		game.g.draw_text(int(x), int(y), item.label,
			size: menu.text_size
			vertical_align: .middle
			align: if menu.step_dir == .right {
				.right
			} else {
				.left
			}
			bold: menu.bold
			italic: menu.italic
			mono: menu.monospaced
			color: color
		)
	}
}

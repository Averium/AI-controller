package renderer

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

import CONST "../constant"
import "../pendulum"
import "../ui"


M_TO_PIX : f32 : 500.0
PIX_TO_M : f32 : 1.0 / M_TO_PIX

// Pre-scaled pixel dimensions
W: f32
H: f32
R: f32
L: f32

debug_y: f32 = 10.0


// Call this once in main() after rl.InitWindow()
init :: proc() {
    // Pre-scaled pixel dimensions
    W = CONST.PENDULUM.CART_WIDTH * M_TO_PIX
    H = CONST.PENDULUM.CART_HEIGHT * M_TO_PIX
    R = CONST.PENDULUM.PENDULUM_RADIUS * M_TO_PIX
    L = CONST.PENDULUM.PENDULUM_LENGTH * M_TO_PIX
}


draw_pendulum :: proc(p: pendulum.PendulumPose) {
    debug_y = 10.0

    cart_center_x := (f32(CONST.SETTINGS.SCREEN_WIDTH) / 2.0) + (p.x * M_TO_PIX)
    cart_center_y := f32(CONST.SETTINGS.SCREEN_HEIGHT) * 2.0 / 3.0

    pendulum_tip_x := cart_center_x - L * math.sin(p.fi)
    pendulum_tip_y := cart_center_y - L * math.cos(p.fi)

    cart_rect_x := i32(cart_center_x - W / 2.0)
    cart_rect_y := i32(cart_center_y - H / 2.0)
    
    rl.DrawRectangle(cart_rect_x, cart_rect_y, i32(W), i32(H), rl.RED)

    cart_center_vector := rl.Vector2{cart_center_x, cart_center_y}
    pendulum_tip_vector := rl.Vector2{pendulum_tip_x, pendulum_tip_y}

    rl.DrawLineEx(cart_center_vector, pendulum_tip_vector, 5.0, rl.DARKGRAY)

    rl.DrawCircle(i32(pendulum_tip_x), i32(pendulum_tip_y), R, rl.RED)
    rl.DrawCircle(i32(cart_center_x), i32(cart_center_y), R/2, rl.DARKGRAY)
}


draw_widget :: proc(widget: ui.Widget) {

    style: ui.Style = ui.ui.styles[widget.style_id]

    switch &data in widget.data {
        case ui.EmptyData:
            rl.DrawRectangleRec(widget.layout, style.text_color[.INACTIVE])
        case ui.BoolData:
            rl.DrawRectangleRec(widget.layout, style.text_color[.INACTIVE])
        case ui.TextData:
            rl.DrawRectangleRec(widget.layout, style.text_color[.INACTIVE])
        case ui.FloatData:

            value_label: cstring = fmt.ctprintf("%.2f", data.value)
            
            label_pos: rl.Vector2 = {widget.layout.x, widget.layout.y}
            value_pos: rl.Vector2 = {widget.layout.x + widget.layout.width, widget.layout.y}

            rl.DrawTextEx(ui.ui.FONT, data.label,  label_pos, f32(style.font_size), ui.ui.FONT_SPACING, style.text_color[.INACTIVE])
            rl.DrawTextEx(ui.ui.FONT, value_label, value_pos, f32(style.font_size), ui.ui.FONT_SPACING, style.data_color[.INACTIVE])

        case ui.PlotData:
            rl.DrawRectangleRec(widget.layout, style.text_color[.INACTIVE])
    }
}

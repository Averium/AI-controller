package renderer

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

import CONST "../constant"
import pendulum "../pendulum"

M_TO_PIX : f32 : 500.0
PIX_TO_M : f32 : 1.0 / M_TO_PIX

// Pre-scaled pixel dimensions
W: f32
H: f32
R: f32
L: f32

// Global font handle for the renderer
FONT: rl.Font
FONT_SPACING: f32 = 1.0

debug_y: f32 = 10.0


// Call this once in main() after rl.InitWindow()
init :: proc() {
    FONT = rl.LoadFontEx("C:/Windows/Fonts/courbd.ttf", CONST.SETTINGS.FONT_SIZE, nil, 0)
    // Pre-scaled pixel dimensions
    W = CONST.PENDULUM.CART_WIDTH * M_TO_PIX
    H = CONST.PENDULUM.CART_HEIGHT * M_TO_PIX
    R = CONST.PENDULUM.PENDULUM_RADIUS * M_TO_PIX
    L = CONST.PENDULUM.PENDULUM_LENGTH * M_TO_PIX
}

cleanup :: proc() {
    rl.UnloadFont(FONT)
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

draw_debug_info :: proc(text: string, data: f32, color_1: rl.Color = rl.DARKGRAY, color_2: rl.Color = rl.DARKGRAY) {
    
    pos := rl.Vector2{10.0, debug_y}
    debug_y += f32(CONST.SETTINGS.FONT_SIZE)

    text_cstr := fmt.ctprintf(text)
    data_cstr := fmt.ctprintf("%.2f", data)

    text_size: rl.Vector2 = rl.MeasureTextEx(FONT, text_cstr, f32(CONST.SETTINGS.FONT_SIZE), FONT_SPACING)

    rl.DrawTextEx(FONT, text_cstr, pos, f32(CONST.SETTINGS.FONT_SIZE), FONT_SPACING, color_1)
    pos.x += text_size.x
    rl.DrawTextEx(FONT, data_cstr, pos, f32(CONST.SETTINGS.FONT_SIZE), FONT_SPACING, color_2)
}
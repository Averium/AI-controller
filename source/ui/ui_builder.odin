package ui

import "vendor:vulkan"
import rl "vendor:raylib"

import "core:fmt"
import "core:strings"

import CONST "../constant"


UIContext :: struct {
    widgets: [dynamic]Widget,
    styles: [dynamic]Style,
    group_mask: GroupMask,

    FONT: rl.Font,
    FONT_SIZE: u8,
    FONT_SPACING: f32,
}


ui: UIContext

style_red: u8
style_blue: u8

sim_time_label: ^Widget
ren_time_label: ^Widget


init :: proc() {
    ui.FONT = rl.LoadFontEx("C:/Windows/Fonts/courbd.ttf", i32(CONST.SETTINGS.FONT_SIZE), nil, 0)
    ui.FONT_SPACING = 1.0

    style_red: u8 = style(
        font_size = CONST.SETTINGS.FONT_SIZE,
        text_color_inactive = rl.Color{30, 30, 30, 255},
        text_color_active = rl.Color{40, 40, 40, 255},
        data_color_inactive = rl.Color{80, 0, 0, 255},
        data_color_active = rl.Color{120, 0, 0, 255}
    )


    style_blue: u8 = style(
        font_size = CONST.SETTINGS.FONT_SIZE,
        text_color_inactive = rl.Color{30, 30, 30, 255},
        text_color_active = rl.Color{40, 40, 40, 255},
        data_color_inactive = rl.Color{30, 30, 100, 255},
        data_color_active = rl.Color{60, 60, 150, 255}
    )

    sim_time_label = data_label(rl.Vector2{10, 10}, "Simulation time [ms]: ", 0.0, style_red)
    ren_time_label = data_label(rl.Vector2{10, 40}, "Rendering time  [ms]: ", 0.0, style_blue)

}



style :: proc(
    font_size: u8,
    text_color_inactive: rl.Color,
    text_color_active: rl.Color,
    data_color_inactive: rl.Color,
    data_color_active: rl.Color,
) -> (id: u8) {

    if len(ui.styles) >= 128 {
        fmt.println("Maximum number of styles reached [128]")
        return 128
    }

    new_style: Style

    new_style.text_color = {
        .INACTIVE = text_color_inactive,
        .ACTIVE = text_color_active,
    }

    new_style.data_color = {
        .INACTIVE = data_color_inactive,
        .ACTIVE = data_color_active,
    }

    new_style.font_size = font_size

    append(&ui.styles, new_style)
    return u8(len(ui.styles) - 1)

}


@(private)
new_text_widget :: proc(position: rl.Vector2, text: string, style_id: u8, group: Group = .MAIN) -> (widget: Widget) {
    style: ^Style = &ui.styles[style_id]
    c_text: cstring = strings.clone_to_cstring(text)

    text_size: rl.Vector2 = rl.MeasureTextEx(ui.FONT, c_text, f32(style.font_size), ui.FONT_SPACING)

    widget.style_id = style_id
    widget.group = group

    widget.layout.width = text_size.x
    widget.layout.height = text_size.y
    widget.layout.x = position.x
    widget.layout.y = position.y

    return
}


text_label :: proc(position: rl.Vector2, label: string, style_id: u8, group: Group = .MAIN) -> ^Widget {

    widget: Widget = new_text_widget(position, label, style_id, group)

    widget.data = TextData{ label = strings.clone_to_cstring(label) }

    append(&ui.widgets, widget)
    return &(ui.widgets[len(ui.widgets) - 1])

}


data_label :: proc(position: rl.Vector2, label: string, value: f32, style_id: u8, group: Group = .MAIN) -> ^Widget {

    widget: Widget = new_text_widget(position, label, style_id, group)

    widget.data = FloatData{
        label = strings.clone_to_cstring(label),
        value = value
    }

    append(&ui.widgets, widget)
    return &(ui.widgets[len(ui.widgets) - 1])
}

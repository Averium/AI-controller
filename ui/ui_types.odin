package ui_types


import "../plotter"

import rl "vendor:raylib"


// WIDGET SPECIFIC DATA STRUCTURES //

EmptyData :: struct {}

TextData :: struct { label: string }

BoolData :: struct { label: string, state: bool }

FloatData :: struct { label: string,  value: f32 }

PlotData :: struct {
    label: string,
    series: []plotter.Plot,
    upper_bound: f32,
    lower_bound: f32,
}


// TAGGED UNION FOR WIDGET DATA //
WidgetData :: union {
    EmptyData,
    TextData,
    BoolData,
    FloatData,
    PlotData,
}


// STYLE (RENDERING) RELATED STUFF //

WidgetColor :: enum u8 {
    INACTIVE,
    ACTIVE,
}


WidgetStyle :: struct {
    font_size: i8,
    text_color: [WidgetColor]rl.Color,
    data_color: [WidgetColor]rl.Color,
}


// MAIN DATA STRUCTURE //
Widget :: struct {
    style_id:  u8,
    parent_id: u16,
    widget_id: u16,
    layout: rl.Rectangle,
    type: WidgetData,
}
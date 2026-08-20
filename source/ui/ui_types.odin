package ui_types


import "../plotter"

import rl "vendor:raylib"


// Widget specific data structures //

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


// Tagged union of widget data //

WidgetData :: union {
    EmptyData,
    TextData,
    BoolData,
    FloatData,
    PlotData,
}


// Style (rendering) related types //

WidgetColor :: enum u8 {
    INACTIVE,
    ACTIVE,
}


WidgetStyle :: struct {
    font_size: i8,
    text_color: [WidgetColor]rl.Color,
    data_color: [WidgetColor]rl.Color,
}



// main data structure //
Widget :: struct {
    style_id:  u8,
    parent_id: u16,
    widget_id: u16,
    layout: rl.Rectangle,
    type: WidgetData,
}
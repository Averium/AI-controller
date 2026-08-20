package ui


import "../plotter"

import rl "vendor:raylib"


Group :: enum u8 {
    MAIN,
    PLOT,
    DEBUG,
}

@(private)
GroupMask :: bit_set[Group; u8]


// Style (rendering) related types //

@(private)
Color :: enum u8 {
    INACTIVE,
    ACTIVE,
}


Style :: struct {
    font_size: u8,
    text_color: [Color]rl.Color,
    data_color: [Color]rl.Color,
}


// Widget specific data structures //

EmptyData :: struct {}

TextData :: struct { label: cstring }

BoolData :: struct { label: cstring, state: bool }

FloatData :: struct { label: cstring,  value: f32 }

PlotData :: struct {
    label: cstring,
    series: []plotter.Plot,
    upper_bound: f32,
    lower_bound: f32,
}

@(private)
WidgetData :: union {
    
    // Tagged union of widget data //

    EmptyData,
    TextData,
    BoolData,
    FloatData,
    PlotData,
}


Widget :: struct {

    // main data structure //

    style_id:  u8,
    layout: rl.Rectangle,
    group: Group,
    data: WidgetData,
}
package plotter


import rl "vendor:raylib"


BUFFER_SIZE: i32: 1000


Plot :: struct {
    title: string,
    unit: string,
    visible: bool,

    data_index: i32,
    data_buffer: [BUFFER_SIZE]f32
}


create :: proc(title: string, unit: string) -> (plot: Plot) {
    plot.title = title
    plot.unit = unit

    plot.data_index = 0

    return
}


add_data_point :: proc(plot: ^Plot, data: f32) {
    plot.data_index = (plot.data_index + 1) % BUFFER_SIZE
    plot.data_buffer[plot.data_index] = data
} 
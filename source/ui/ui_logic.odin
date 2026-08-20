package ui


set_value :: proc(widget: ^Widget, value: f32) {
    #partial switch &data in widget.data {
        case FloatData:
            data.value = value
    }
}
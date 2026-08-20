package file

import "core:os"
import "core:fmt"
import "core:encoding/json"


load_data :: proc(filename: string, struct_ptr: any) -> bool {

    data, read_error := os.read_entire_file(filename, context.allocator)
    if read_error != nil {
        fmt.eprintf("Failed to read file: %s\n", filename)
        return false
    }

    defer delete(data)

    decode_error := json.unmarshal_any(data, struct_ptr)
    if decode_error != nil {
        fmt.println("Error parsing JSON:", decode_error)
        return false
    }

    return true
}
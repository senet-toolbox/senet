const std = @import("std");
const App = @import("app.zig");
export fn init(window_width: f32, window_height: f32) void {
    App.instantiate(window_width, window_height, std.heap.wasm_allocator);
}

pub fn main() !void {}

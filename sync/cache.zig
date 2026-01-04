// ============ cache_layer.zig (Module A) ============
const std = @import("std");

var cache = std.StringHashMap([]const u8).init(std.heap.wasm_allocator);

// Exported functions for the host to call
export fn cache_get(key_ptr: [*]const u8, key_len: usize, out_ptr: [*]u8, out_max: usize) i32 {
    const key = key_ptr[0..key_len];
    if (cache.get(key)) |value| {
        if (value.len > out_max) return -1; // buffer too small
        @memcpy(out_ptr[0..value.len], value);
        return @intCast(value.len);
    }
    return -2; // not found
}

export fn cache_set(key_ptr: [*]const u8, key_len: usize, val_ptr: [*]const u8, val_len: usize) i32 {
    const key = key_ptr[0..key_len];
    const val = val_ptr[0..val_len];

    // Need to dupe since the host memory is transient
    const owned_key = std.heap.wasm_allocator.dupe(u8, key) catch return -1;
    const owned_val = std.heap.wasm_allocator.dupe(u8, val) catch return -1;

    cache.put(owned_key, owned_val) catch return -1;
    return 0;
}

export fn allocUint8(len: usize) ?[*]u8 {
    const slice = std.heap.wasm_allocator.alloc(u8, len) catch return null;
    return slice.ptr;
}

export fn dealloc(ptr: [*]u8, len: usize) void {
    std.heap.wasm_allocator.free(ptr[0..len]);
}

fn main() void {}



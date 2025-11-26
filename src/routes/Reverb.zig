const std = @import("std");
const Reverb = @import("reverb");

fn ping(ctx: *Reverb.Context) !void {
    try ctx.STRING("Hello World!");
}

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init();
    defer if (gpa.deinit() != .ok) @panic("Memmory leak...");
    const allocator = gpa.allocator();

    const server = .new(.{}, allocator);

    try server.get("/", ping, &.{});

    try server.listen();
}


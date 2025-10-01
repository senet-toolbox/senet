const std = @import("std");
const Server = @import("lib/server.zig");
const Context = @import("lib/context.zig");

const Next = Server.Next;

fn ping(ctx: *Context) !void {
    try ctx.STRING("SUCCESS");
}

fn middleware(next: Next, ctx: *Context) !Next {
    std.debug.print("This is the paylod, ie the body of the HTTP Request: {s}\n", .{ctx.http_payload});
    std.log.debug("This is a Middleware Function", .{});
    return next;
}

fn middleware_second(next: Next, _: *Context) !Next {
    std.log.debug("This is the second middleware function", .{});
    return next;
}

pub fn main() !void {
    var server: Server = undefined;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("Memmory leak...");
    var allocator = gpa.allocator();

    const loom_config = Server.Config{};

    try server.new(loom_config, &allocator, null);
    try server.get("/ping", ping, &.{ middleware, middleware_second });
    try server.listen();
}

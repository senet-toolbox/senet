const std = @import("std");
const Reverb = @import("reverb");
const Server = Reverb.Server;
const Context = Reverb.Context;

fn ping(ctx: *Context) !void {
    try ctx.STRING("Pong");
}
pub fn main() !void {
    var server: Server = undefined;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("Memmory leak...");
    var allocator = gpa.allocator();

    const reverb_config = Server.Config{
        .server_addr = "127.0.0.1",
        .server_port = 8443,
    };

    try server.new(reverb_config, &allocator);
    try server.addRoute("/ping", "GET", ping, &.{});
    try server.listen();
}

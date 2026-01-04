const std = @import("std");
const loom = @import("loom");
const Server = @import("reverb").Server;
const Context = @import("reverb").Context;
const Websocket = loom.WebSocket;

fn onConnection(ws: *Websocket) !void {
    std.debug.print("onConnection\n", .{});
    try ws.sendText("Hello from Reverb!");
}

fn onMessage(ws: *Websocket, message: Websocket.Message) !void {
    switch (message) {
        .Text => |text| {
            std.debug.print("Text: {s}\n", .{text});
        },
        .Binary => |binary| {
            std.debug.print("Binary: {any}\n", .{binary});
        },
        .Pong => |pong| {
            std.debug.print("Pong: {any}\n", .{pong});
        },
        .Close => |close| {
            std.debug.print("Close: {any}\n", .{close});
        },
        else => {},
    }
    try ws.sendText("This is onMessage send");
}

pub fn main() !void {
    var allocator = std.heap.page_allocator;

    var server: Server = undefined;
    const loom_config = Server.Config{
        .max = 1024,
    };
    try server.new(loom_config, &allocator, null);

    try server.useWss(.{
        .onConnection = onConnection,
        .onMessage = onMessage,
        .max_body_size = 1024,
    });

    try server.listen();
}

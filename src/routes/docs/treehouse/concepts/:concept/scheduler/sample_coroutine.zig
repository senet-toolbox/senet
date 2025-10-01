const std = @import("std");
const Reverb = @import("reverb");
const Server = Reverb.Server;
const Context = Reverb.Context;
const Loom = Reverb.Engine.Loom;
const Scheduler = Reverb.Engine.Scheduler;
const createFiber = Scheduler.createFiber;
const activate = Scheduler.activate;
const xresume = Scheduler.xresume;
const xsuspend = Scheduler.xsuspend;

const Next = Server.Next;
var loom: Loom = undefined;

fn fiber_response(ctx: *Context) !void {
    try ctx.STRING("SUCCESS");
    // Suspends this fiber and resumes the calling fiber
    xsuspend();
}

fn ping(ctx: *Context) !void {
    const stack = try loom.scheduler.stackAlloc(null);
    defer loom.scheduler.freeStack(stack);
    const fiber = try createFiber(fiber_response, .{ctx}, stack);
    // We start the fiber
    activate(fiber);
}

pub fn main() !void {
    var server: Server = undefined;
    var allocator = std.heap.c_allocator;
    const loom_config = Server.Config{};

    try server.new(loom_config, &allocator, null);
    try server.get("/ping", ping, &.{});

    loom = Server.instance.loom;

    try server.listen();
}


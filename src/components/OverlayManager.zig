const Vapor = @import("vapor");
const std = @import("std");
const EvtInstNode = Vapor.lib.EvtInstNode;
const EvtInst = Vapor.lib.EvtInst;
const Event = Vapor.Event;
const EventType = Vapor.Types.EventType;
const OverlayManager = @This();

const Item = struct {
    id: usize,
    node: *EvtInstNode,
};

var stack: Vapor.Array(Item) = undefined;

pub fn init() void {
    stack = Vapor.array(Item, .persist);
    _ = Vapor.lib.addGlobalListener(.keydown, onKeyDown);
}

fn onKeyDown(evt: *Vapor.Event) void {
    if (stack.items.len == 0) return;
    const key = evt.key();
    if (std.mem.eql(u8, key, "Escape") or std.mem.eql(u8, "Return", key) or std.mem.eql(u8, "Enter", key) or std.mem.eql(u8, "Tab", key)) {
        const last = stack.items.len - 1;
        const item = stack.items[last];
        const node = item.node;
        @call(.auto, node.data.evt_cb, .{ &node.data, evt });
    }

    if (std.mem.eql(u8, key, "0") or std.mem.eql(u8, key, "1") or std.mem.eql(u8, key, "2") or std.mem.eql(u8, key, "3") or std.mem.eql(u8, key, "4") or std.mem.eql(u8, key, "5") or std.mem.eql(u8, key, "6") or std.mem.eql(u8, key, "7") or std.mem.eql(u8, key, "8") or std.mem.eql(u8, key, "9")) {
        const last = stack.items.len - 1;
        const item = stack.items[last];
        const node = item.node;
        @call(.auto, node.data.evt_cb, .{ &node.data, evt });
    }

    if ((std.mem.eql(u8, key, "k") or std.mem.eql(u8, key, "x")) and evt.metaKey()) {
        const last = stack.items.len - 1;
        const item = stack.items[last];
        const node = item.node;
        @call(.auto, node.data.evt_cb, .{ &node.data, evt });
    }

    if (std.mem.eql(u8, key, "ArrowDown") or std.mem.eql(u8, key, "ArrowUp") or std.mem.eql(u8, key, "ArrowLeft") or std.mem.eql(u8, key, "ArrowRight")) {
        const last = stack.items.len - 1;
        const item = stack.items[last];
        const node = item.node;
        @call(.auto, node.data.evt_cb, .{ &node.data, evt });
    }
}

pub fn register(event_type: EventType, callback: anytype, args: anytype) void {
    const Args = @TypeOf(args);
    const Closure = struct {
        arguments: Args,
        evt_node: EvtInstNode = .{ .data = .{ .evt_cb = runFn, .deinit = deinitFn } },
        //
        fn runFn(evt_inst: *EvtInst, evt: *Event) void {
            const evt_node: *EvtInstNode = @fieldParentPtr("data", evt_inst);
            const closure: *@This() = @alignCast(@fieldParentPtr("evt_node", evt_node));
            @call(.auto, callback, .{ closure.arguments, evt });
        }
        //
        fn deinitFn(node: *EvtInstNode) void {
            const closure: *@This() = @alignCast(@fieldParentPtr("evt_node", node));
            Vapor.arena(.persist).destroy(closure);
        }
    };

    const closure = Vapor.arena(.persist).create(Closure) catch |err| {
        Vapor.print("Error could not create closure {any}\n ", .{err});
        unreachable;
    };
    closure.* = .{
        .arguments = args,
    };

    closure.evt_node.evt_type = event_type;

    const stable_id = @intFromEnum(event_type) + @intFromPtr(args);
    stack.append(.{ .id = stable_id, .node = &closure.evt_node }) catch unreachable;
}

pub fn unregister(event_type: EventType, args: anytype) void {
    const stable_id = @intFromEnum(event_type) + @intFromPtr(args);
    for (stack.items, 0..) |item, i| {
        if (item.id == stable_id) {
            _ = stack.orderedRemove(i);
            return;
        }
    }
}

const std = @import("std");
const Fabric = @import("fabric");
const Kit = Fabric.Kit;
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;

const User = struct {
    uuid: []const u8 = "",
    name: []const u8 = "",
    email: []const u8 = "",
};

var user: User = .{};
fn init() void {}

fn onCreate() void {
    Kit.fetch("/user?id=123", setUserName, .{ .method = .GET, .use_credentials = true });
}

fn setUserName(response: *Kit.Response) void {
    const parsed = Kit.glue(User, response.body) catch return;
    user = parsed.value;
}

pub fn render() void {
    // Since the onCreate Function only runs when Static.Box, and Pure are added to the dom, then making
    // the fetch call after will work and update the DOM
    Static.Hooks(.{ .on_create = onCreate })({
        Static.Box(.{})({
            Pure.AllocText("Fetched username: {s}", .{user.name}, .{});
        });
    });
}

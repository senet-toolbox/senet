const std = @import("std");
const Fabric = @import("fabric");
const Kit = Fabric.Kit;
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;

const Users = struct {
    uuid: []const u8,
    name: []const u8,
    email: []const u8,
};

var users: Signal(?[]Users) = undefined;
fn init() void {
    users.init(null);
}

fn getUsers() void {
    // we pass the url and the callback to call when the data has returned.
    // this mean that the application does not pause its executation, we treat fetching as a request response.
    Kit.fetch("http://localhost:8443/api/users", parseUsers, .{
        .method = .GET,
        .use_credentials = true,
    });
}

fn parseUsers(resp: Kit.Response) void {
    const parsed = Kit.glue([]Users, resp.body) catch {};
    users.init(parsed.value);
}

pub fn render() void {
    // If the users list is not null then we load the users.
    if (users.get()) |users_list| {
        for (users_list) |user| {
            Pure.Text(user.uuid, .{});
            Pure.Text(user.name, .{});
        }
    } else {
        Pure.Text("Awaiting Users from database!", .{});
    }
}

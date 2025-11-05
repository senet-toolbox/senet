const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;

var show_notification: Signal(bool) = undefined;
fn init() void {
    show_notification.init(false);
}

fn toggleNotification() void {
    show_notification.set(true);
}

fn render() void {
    Static.Button(.{ .onPress = toggleNotification }, .{})({
        Static.Text("Show Notification", .{});
    });
}

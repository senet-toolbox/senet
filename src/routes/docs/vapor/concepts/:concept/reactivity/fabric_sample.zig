const Fabric = @import("fabric");
const Static = Fabric.Static;

fn log() void {}
fn myButton() void {
    Static.Button(.{ .onPress = log }, .{})({
        Static.Text("I'm a button", .{});
    });
}

pub fn render() void {
    Static.FlexBox(.{ .width = .percent(100), .height = .percent(100) })({
        Static.Header("Welcome to my app", .XXLarge, .{});
        myButton();
    });
}

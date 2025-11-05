const Vapor = @import("fabric");
const Pure = Vapor.Pure;
const Box = Pure.Box;
const TextFmt = Pure.TextFmt;
const Text = Pure.Text;
const Button = Pure.Button;

var counter: usize = 0;
var text: []const u8 = "Increment";

pub fn increment() void {
    counter += 1;
    text = "Increment again";
}

pub fn render() void {
    Button(.{ .on_press = increment }).plain()({
        Text(text).plain();
    });
    TextFmt("{d}", .{counter}).plain();
}

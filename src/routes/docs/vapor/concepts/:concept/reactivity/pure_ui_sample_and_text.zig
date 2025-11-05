const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const TextFmt = Pure.TextFmt;
const Text = Pure.Text; // We changed this to Pure
const Button = Static.Button;

var counter: usize = 0;
var text: []const u8 = "Increment";

pub fn increment() void {
    counter += 1;
    text = "Increment again";
    Fabric.cycle();
}

pub fn render() void {
    Button(.{ .on_press = increment }).plain()({
        Text(text).plain(); // This now updates
    });
    TextFmt("{d}", .{counter}).plain(); // This still updates 
}

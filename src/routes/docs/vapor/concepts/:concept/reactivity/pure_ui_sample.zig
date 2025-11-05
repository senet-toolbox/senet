const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const TextFmt = Pure.TextFmt;
const Text = Static.Text;
const Button = Static.Button;

var counter: usize = 0;

pub fn increment() void {
    counter += 1;
    Fabric.cycle();
}

pub fn render() void {
    Button(.{ .on_press = increment }).plain()({
        Text("Increment").plain();
    });
    TextFmt("{d}", .{counter}).plain(); // Only this updates
}

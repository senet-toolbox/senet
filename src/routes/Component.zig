// All normal Zig code
const Fabric = @import("fabric");
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;

// Components
const Box = Static.Box;
const Button = Static.Button;
const Icon = Static.Icon;
const TextFmt = Pure.TextFmt;

// Style struct for the Box component
const box_style = Style{
    .layout = .center,
    .size = .{ .width = .px(100), .height = .px(100) },
};

var counter: usize = 0;
fn increment() void {
    counter += 1;
    Fabric.cycle(); // Updates the UI
}

// Render
pub fn render() void {
    // This is all normal Zig code!
    TextFmt("{d}", .{counter}).plain(); // React: <Text>{counter}</Text>
    // A component with children
    Box.style(&box_style)({
        const icon: []const u8 = "bi bi-plus";
        Button(.{ .on_press = increment }).style(&.{ .size = .square_px(100) })({
            Icon(icon).plain(); // A component without children
        });
    });
}

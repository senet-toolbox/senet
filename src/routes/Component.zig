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
    Fabric.cycle(); // Call to updates the UI
}

// Render
pub fn render() void {
    // This is all normal Zig code!
    // A component with children
    Box.style(&box_style)({
        Button(.{ .on_press = increment }).size(.square_px(100)).body()({
            TextFmt("{d}", .{counter}).plain(); // React: <Text>{counter}</Text>
        });
    });
}

// All normal Zig code
const Vapor = @import("vapor");
const Style = Vapor.Style;
const Static = Vapor.Static;
const Pure = Vapor.Pure;

// Components
const Box = Static.Box;
const Button = Static.Button;
const TextFmt = Pure.TextFmt;
const Text = Static.Text;

// Style struct for the Box component
const box_style = Style{
    .layout = .left_center,
    .child_gap = 8,
    .size = .{ .width = .grow, .height = .fit },
};

var counter: usize = 0;
fn increment() void {
    counter += 1;
}

// Render
pub fn render() void {
    Box.style(&box_style)({
        // Chaining styles
        Button(.{ .on_press = increment })
            .border(.simple(.palette(.border_color_light)))
            .body()({
            Text("Increment")
                .font(18, null, .palette(.text_color))
                .close();
        });
        TextFmt("{d}", .{counter})
            .font(24, 700, .palette(.text_color))
            .close();
    });
}

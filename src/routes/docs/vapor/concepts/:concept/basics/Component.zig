const Fabric = @import("fabric");
const Style = Fabric.Style;
const Static = Fabric.Static;
const Box = Static.Box;
const Text = Static.Text;

// Initialization
var init_text: []const u8 = "";
const background_color = &Style{ .background = .hex("#ffffff") };

pub fn init() void {
    init_text = "I was created in init()";
}

// Render
pub fn render() void {
    // 👇 &.{} is the style struct, if we pass it we can make use of default values
    Box.style(&.{})({}); // 👈 {} is passed, now we can run any zig code inside
    Box.style(&.{})({
        const name: []const u8 = "Hi I'm Fabric!"; // normal zig code
        Text(name).style(&.{ .font_size = 24 }); // 👈 style the text
    });
    // I am a component that takes children
    Box.style(background_color)({
        // I am a component that cannot take children
        Text("I am a component!").plain();
        // And so am I!
        Text(init_text).plain();
    });
}










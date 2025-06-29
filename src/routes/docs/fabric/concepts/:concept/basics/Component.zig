const Fabric = @import("fabric");
const Style = Fabric.Style;
const Static = Fabric.Static;

// Initialization
var init_text: []const u8 = "";

pub fn init() void {
    init_text = "I was created in init()";
}

// Render
pub fn render() void {
    Static.FlexBox(.{})({}); // 👈 {} is passed ie void, now we can run any zig code inside the empty braces;
    // I am a component that takes children
    Static.FlexBox(Style{
        .background = .hex("#ffffff"),
        // 👇 {} is passed ie void, now we can run any zig code inside the empty braces
    })({
        // I am a component that cannot take children
        Static.Text("I am a component!", .{});
        // And so am I!
        Static.Text(init_text, .{});
    });
}


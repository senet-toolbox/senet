const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;

var text: []const u8 = "Hello World";
fn render() void {
    Static.Text(text).plain(); // I will never change
    Pure.Text(text).plain(); // I will change if I need to
}

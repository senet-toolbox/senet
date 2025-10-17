const Fabric = @import("fabric");
const Button = Fabric.Static.Button;
const TextFmt = Fabric.Pure.TextFmt;

var counter: u32 = 0;
fn increment() void {
    counter += 1;
    Fabric.cycle();
}

pub fn render() void {
    Button(.{ .on_press = increment }).style(&.{
        .size = .hw(.px(38), .percent(10)),
        .visual = .pill(.hex("#E5FF54")),
    })({
        TextFmt("{d}", .{counter})
            .style(&.{ .visual = .font(18, 500, .hex("#262626")) });
    });
}

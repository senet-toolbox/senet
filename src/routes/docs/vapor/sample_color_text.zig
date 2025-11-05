const Fabric = @import("fabric");
-- const Button = Fabric.Static.Button;
++ const Button = Fabric.Pure.Button;
const TextFmt = Fabric.Pure.TextFmt;

var counter: u32 = 0;
++ var color: Fabric.Types.Color = .red;
fn increment() void {
    counter += 1;
    ++ color = if (counter % 2 == 0) .red else .blue;
    Fabric.cycle();
}

pub fn render() void {
    Button(.{ .on_press = increment }).style(&.{
        .size = .hw(.px(38), .percent(10)),
        -- .visual = .pill(.hex("#E5FF54")),
        ++ .visual = .pill(color), // we are now using the color variable
    })({
        TextFmt("{d}", .{counter})
            .style(&.{ .visual = .font(18, 500, .hex("#262626")) });
    });
}

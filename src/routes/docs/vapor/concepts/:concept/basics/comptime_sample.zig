const Vapor = @import("vapor");
const Signal = Vapor.Signal;
const Static = Vapor.Static;

pub fn Counter(comptime T: type) type {
    return struct {
        var count: T = 0;

        fn increment() void {
            count += 1;
        }

        fn decrement() void {
            count -= 1;
        }

        pub fn render() void {
            Static.Box().layout(.center).spacing(16).padding(.all(20)).body()({
                Static.Button(.{ .on_press = decrement })
                    .padding(.all(8))
                    .border(.simple(.palette(.border_color_light)))
                    .cursor(.pointer)
                    .body()({
                    Static.Text("-").font(18, null, .palette(.text_color)).end();
                });

                Static.TextFmt("Global State: {d}", .{count}).font(24, 700, .palette(.text_color)).end();

                Static.Button(.{ .on_press = increment })
                    .padding(.all(8))
                    .border(.simple(.palette(.border_color_light)))
                    .cursor(.pointer)
                    .body()({
                    Static.Text("+").font(18, null, .palette(.text_color)).end();
                });
            });
        }
    };
}

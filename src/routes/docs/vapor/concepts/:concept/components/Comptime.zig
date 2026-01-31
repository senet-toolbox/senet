const Vapor = @import("vapor");
const Box = Vapor.Box;
const Button = Vapor.Button;
const Text = Vapor.Text;
const TextFmt = Vapor.TextFmt;

pub fn Counter(comptime T: type, initial_value: T) type {
    return struct {
        var count: T = initial_value;

        fn increment() void {
            count += 1;
        }

        fn decrement() void {
            if (count == 0 and T == u32) {
                Vapor.alert("You can't go negative! On a u32", .{});
                return;
            }
            count -= 1;
        }

        pub fn render() void {
            Box().layout(.center).spacing(16).padding(.all(20)).children({
                Button(decrement)
                    .shadow(.card(.palette(.text_color)))
                    .padding(.all(8))
                    .border(.simple(.palette(.text_color)))
                    .background(.palette(.background))
                    .duration(100)
                    .hoverScale()
                    .width(.percent(20))
                    .cursor(.pointer)
                    .children({
                    Text("-").font(18, null, .palette(.text_color)).end();
                });

                if (T == u32) {
                    TextFmt("u32 Counter: {d}", .{count}).font(24, 700, .palette(.text_color)).end();
                } else {
                    TextFmt("i32 Counter: {d}", .{count}).font(24, 700, .palette(.text_color)).end();
                }

                Button(increment)
                    .shadow(.card(.palette(.text_color)))
                    .padding(.all(8))
                    .border(.simple(.palette(.text_color)))
                    .background(.palette(.background))
                    .duration(100)
                    .hoverScale()
                    .width(.percent(20))
                    .cursor(.pointer)
                    .children({
                    Text("+").font(18, null, .palette(.text_color)).end();
                });
            });
        }
    };
}

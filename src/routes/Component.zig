// All normal Zig code
const Vapor = @import("vapor");

var counter: i32 = 0;
fn increment() void { counter += 1; }
fn decrement() void { counter -= 1; }

// Render
pub fn ButtonComponent() void {
    Button(increment).hoverScale().border(.simple).children({
        Text("+").bold().end();
    });

    Text(counter).font(24, 700, .palette(.tint)).end();

    Button(decrement).hoverScale().border(.simple).children({
        Text("-").bold().end();
    });
}

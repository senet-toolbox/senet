// All normal Zig code
const Vapor = @import("vapor");

// 🔥 No useState gymnastics
var counter: i32 = 0;
fn increment() void { counter += 1; }
fn decrement() void { counter -= 1; }

// Render
pub fn ButtonComponent() void {
    Button(increment).children({
        Text("+").end();
    });

    Text(counter).font(24, 700, .blue).end();

    Button(decrement).hoverScale().border(.simple).children({
        Text("-").bold().end();
    });
}

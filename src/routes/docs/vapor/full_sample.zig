const Fabric = @import("fabric");
const Row = Fabric.Static.Row;
const Text = Fabric.Static.Text;
const Style = Fabric.Style;

const User = struct {
    name: []const u8,
    lastname: []const u8,
    age: u32,
};

// Render
pub fn render(user: User) void {
    // Since we are returning a closure we first call the Row(Style{}) function with our styling as an argument.
    // This returns a closure fn(void) void, which is a function that takes a void argument of {} and returns nothing.
    Row(Style{})({
        // Now we call our code block, and at the end we return void, to the function that we initially returned.
        Fabric.println("Hello {s} {s}", .{ user.name, user.lastname });
        Text(user.name, Style{});
        // 👈 We are at the end and so we return nothing ie void.
    });

    // First Row(Style{}) is called with Style{} as an argument, which returns a closure, fn (void) void;
    // Then we call the code block. printing "Hello {s} {s}", .{ user.name, user.lastname };
    // Then we call Text(user.name, Style{}); which is a function a string and a style, and returns void.
    // return we return void at the end of the code block.
    // which is then passed into our fn (void 👈) void; which returns nothing.

    // This also works
    const closure = Row(Style{}); // fn (void) void
    closure({
        Fabric.println("Hello {s} {s}", .{ user.name, user.lastname });
        Text(user.name, Style{});
    });
}

const std = @import("std");
fn main() !void {
    var a: usize = 0;
    a += 1;

    // This is a code block, where we can run anything inside it.
    // But it is scoped to said block therefore the variable only live inside here.
    {
        var b: usize = 0;
        b += 1;
        std.log.debug("We can access 'b' here {d}", .{b});
    }

    std.log.debug("We can access 'a' here {d}", .{a});
    // We cannot access 'b' here

    // First the code block will run then run_void_code_block will run since {} returns void
    run_void_code_block({
        var c: usize = 0;
        c += 1;
        std.log.debug("We can access 'c' here {d}", .{c});
    });
}

fn run_void_code_block(_: void) void {}

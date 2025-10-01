fn counterFunc(x: *usize) !void {
    // We increment the counter
    x.* += 1;
    //xsuspend suspends the current stack we are popping from. and Resumes the previous stack, we were using;
    xsuspend();
    //We increment the counter again
    x.* += 3;
    //We suspend the current stack, and resume the previous stack
    xsuspend();
    //We increment the counter again
    x.* += 5;
}

pub fn main() !void {
    const allocator = std.testing.allocator;
    // We create a Scheduler instance, the scheduler holds and handles the fibers
    var scheduler: Scheduler = undefined;
    try scheduler.init(allocator);
    // We create a stack, this is the stack that will be used by the fiber that we want to switch to
    const stack = try scheduler.stackAlloc(null);
    // We deallocate the stack when we are done executing the fiber 
    defer allocator.free(stack);
    var counter: usize = 0;
    //The current_fiver, is the fiber that we want to switch to, we pass a function that we want to run
    var current_fiber = try createFiber(counterFunc, .{&counter}, stack);
    // Start the callee fiber 
    // we call resume which swaps out the stack, and switches to our current_fiber, that we pass as an argument
    xresume(current_fiber);
    try std.testing.expectEqual(counter, 1);
    // We resume the current_fiber.
    xresume(current_fiber);
    try std.testing.expectEqual(counter, 4);
    // We resume the current_fiber.
    xresume(current_fiber);
    try std.testing.expectEqual(counter, 9);

    // We check that the fiber is done
    try std.testing.expectEqual(current_fiber.status, .Done);
}

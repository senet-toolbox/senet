const std = @import("std");
const Fabric = @import("fabric");
const Signal = Fabric.Signal;
const Style = Fabric.Style;
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const CodeEditor = @import("../CodeEditor.zig");
const Custom = @import("../../../../../../components/Custom.zig");

var fiber_code_editor: CodeEditor = undefined;
// Initialization
pub fn init() void {
    fiber_code_editor.init(&Fabric.lib.allocator_global, @embedFile("fiber_sample.zig"));
}

pub fn render() void {
    Static.FlexBox(.{
        .child_alignment = .{ .x = .start, .y = .start },
        .child_gap = 8,
        .direction = .column,
        .width = .percent(100),
        .height = .percent(100),
    })({
        Static.Text("Loom", .{
            .font_size = 42,
            .font_weight = 700,
            .text_color = .hex("#1a1a1a"),
        });
        Static.Text("Loom is a single threaded event-loop that is used to handle all incoming requests and responses.", .{
            .font_size = 22,
            .text_color = .hex("#666666"),
            .margin = .{ .bottom = 16 },
        });
        Static.Text(
            \\The loom engine is the backbone of Reverb. It is responsible for handling all incoming requests and responses.
            \\It exposes the Scheduler interface, which is used for dispatching jobs to a multi-threaded, atomic lock-free thread pool.
            \\The Scheduler also exposes a set of async functions, which allow for manual stack frame swapping. This means that instead of 
            \\transpiling to a set of state machines, we manually swap out the stack frame and continue execution.
        , .{
            .font_size = 18,
            .margin = .{ .bottom = 16 },
        });
        Static.Center(.{
            .width = .percent(100),
            .margin = .{ .bottom = 16 },
        })({
            Static.Image("/assets/eventloop.webp", .{
                .width = .mobile_desktop_percent(100, 70),
                .height = .percent(100),
                .margin = .{ .bottom = 32 },
            });
        });
        Static.Text("Frame Stack Pointer Swapping", .{
            .font_size = 32,
            .font_weight = 600,
            .text_color = .hex("#2a2a2a"),
            .margin = .{ .top = 16 },
        });
        Static.Text(
            \\Imagine a set of building blocks; we can stack them on top of each other as much as we want. However, to remove
            \\the blocks we need to take them off the top of the stack. This data structure is called a stack,
            \\also known as LIFO (Last In First Out). When we remove a block from the top, we use one of our hands. Each hand can be considered
            \\a thread. Let's say each block has an action on it that we need to take. To see the action we need to remove the block, then read
            \\the action and execute it. We can only execute one action at a time, right, since we only have one hand.
        , .{
            .font_size = 18,
        });
        Static.Center(.{
            .width = .percent(100),
            .margin = .{ .bottom = 16 },
        })({
            Static.Image("/assets/blocks.webp", .{
                .width = .percent(30),
                .height = .percent(100),
            });
        });
        Static.Text(
            \\In the case below, we are using two stacks. Each stack is made up of a number of frames (blocks). Each frame is a function.
            \\When we execute software, we are executing a series of functions in a certain order. The stack pointer is our hand, i.e., it points 
            \\to the next frame (block) we need to pop off the stack that we need to read and execute. If we wanted to execute another stack's functions,
            \\we would need to swap our hand to pick up frames from the other stack. This is called stack pointer swapping.
        , .{
            .font_size = 18,
        });
        Static.Text(
            \\The way this works in computers and assembly is that we have this concept of registers. Registers are labeled boxes which hold different types of data.
            \\When we want to swap out our stack and start executing another stack's frames, we store the current stack of frames in a set of registers.
            \\Afterwards, we load the new stack of frames we want to execute into another set of registers and move the stack pointer to point to this
            \\stack.
        , .{
            .font_size = 18,
        });
        Static.Image("/assets/stack_swapping.webp", .{
            .width = .percent(100),
            .height = .percent(100),
        });
        Static.Text("Sample Fiber", .{
            .font_size = 32,
            .font_weight = 600,
            .text_color = .hex("#2a2a2a"),
            .margin = .{ .top = 16 },
        });
        Static.Text(
            \\Here we create a fiber, which takes a stack and a function to execute, as well as any arguments.
            \\By default, the stack allocated is a stack of 1024 bytes, which is allocated on the heap.
            \\The main fiber is the current execution context we are always in. We are creating a new stack, which we add functions to.
            \\Then we switch to the new stack and execute said functions.
        , .{
            .font_size = 18,
        });
        Custom.Intersection(.{
            .width = .percent(100),
            .height = .percent(100),
            .margin = .{ .bottom = 32 },
        })({
            fiber_code_editor.render(0);
        });
        Static.Text("The Birthday Cake Problem", .{
            .font_size = 32,
            .font_weight = 600,
            .text_color = .hex("#2a2a2a"),
        });
        Static.Center(.{
            .width = .percent(100),
            .margin = .{ .bottom = 16 },
        })({
            Static.Image("/assets/birthdaycake.webp", .{
                .width = .percent(40),
                .height = .percent(20),
            });
        });
        Static.Text(
            \\The atomic thread pool is lock-free. What does this mean? Basically, there are two types of thread pools: mutex pools
            \\and lock-free pools. Imagine you are back in college, and you have 3 roommates: Banksy, Basquiat, and Bob. Bob has a birthday coming
            \\up, and he needs 4 eggs to make the cake. There are currently 8 eggs in the fridge. Banksy decides to make an omelet and uses 3 eggs.
            \\Basquiat boils 2 for dinner. But no one mentions it to Bob, so the day before his birthday he cannot make his cake.
        , .{
            .font_size = 18,
        });
        Static.Text(
            \\Next year, Bob decides to put a giant lock on the fridge door and locks it. This way, if anyone wants to grab anything from the 
            \\fridge, they have to ask Bob for the key and tell Bob what they took, so that he knows if they use any eggs. The problem with this is
            \\that if Basquiat or Banksy want blueberries, or anything other than eggs, they still need to ask Bob for permission. This leads to a lot 
            \\of wasted time and a lot of unnecessary locking and unlocking.
        , .{
            .font_size = 18,
        });
        Static.Text(
            \\Banksy comes up with an idea the following year: instead of putting a lock on the entire fridge, he locks the eggs themselves in a
            \\lock box. Now anyone can grab anything from the fridge, but if they want to grab any eggs, they need the key to unlock it.
        , .{ .font_size = 18 });
        Static.Text("Atomic Thread Pool", .{
            .font_size = 32,
            .font_weight = 600,
            .text_color = .hex("#2a2a2a"),
            .margin = .{ .top = 16 },
        });
        Static.Text(
            \\The scenario described above is the reason we have mutexes and lock-free pools. In a common scenario where you need to share
            \\data between threads, you need to use a mutex. This is because the threads are not allowed to access the data at the same time.
            \\If they could, we could get undefined behavior, where one thread thinks the counter is 8 and another knows it's 3. Therefore, we use 
            \\a mutex, which is a form of lock that says the thread that holds this lock (mutex) is allowed to read or write to the shared value.
            \\But this creates a lot of overhead and potential issues, such as deadlocks, which can happen if two threads are waiting for the same 
            \\lock and neither knows it's free. The overhead of a mutex is very high; moreover, thread creation is expensive. This is why in many scenarios
            \\increasing the thread count leads to lower performance. Therefore, it is best to offload expensive work like file I/O to thread pools.
            \\The mutex in this case is the giant lock on the fridge door. The lock-free pool is the lock box, which has less overhead and no risk of deadlocks.
        , .{ .font_size = 18 });
        Static.Text("But how does it work?", .{
            .font_size = 32,
            .font_weight = 600,
            .text_color = .hex("#2a2a2a"),
            .margin = .{ .top = 16 },
        });
        Static.Text(
            \\An atomic thread pool uses an atomic operation known as compare and swap. Instead of locking the entire fridge, we look at the current value
            \\and compare it to the value we read beforehand. If the value is the same, then we swap in our new value. For example, let's say there are two threads:
            \\the first thread logs when the counter is even, and the second logs when it's odd. The first thread reads the count of 0, it doesn't log anything, and increments the count.
            \\The value it read is zero, so when it tries to write to the counter in memory, it checks that the counter is still zero, and if so it writes 1 to it.
            \\The second thread read the value of zero, and it is even, so it logs zero and increments the counter. Now it tries to write one to the counter in memory.
            \\Except now the counter is one due to thread 1, so it fails. So instead we call the function again with our current value. Since it's
            \\one, we do not log the value, we increment again and try to write to the counter. Now since the previous value was one and the counter value is still one, we write 2 to it.
        , .{ .font_size = 18 });
        Static.Text(
            \\This is an incredibly important concept to understand. If we are just incrementing a counter, the overhead of mutex exchanging or 
            \\comparing and swapping is very high. There is no point to using a lock-free pool or any thread pool at all, since the mutex is exchanged and only one
            \\thread in the lock-free pool is really doing any work.
        , .{ .font_size = 18 });

        Static.Text("Sample Functions in Scheduler", .{
            .font_size = 24,
            .font_weight = 600,
            .text_color = .hex("#2a2a2a"),
            .margin = .{ .top = 16 },
        });

        Static.Box(.{
            .width = .percent(100),
            .height = .percent(100),
            .border_radius = .all(8),
            .background = .hex("#282a36"),
            .padding = .all(12),
            .margin = .{ .bottom = 32 },
        })({
            Custom.HtmlText(
                \\<code>fn createFiber(func: anytype, args: anytype, stack: Stack) !*Fiber </code>
            , .{ .text_color = .hex("#ffffff") });
        });

        Static.Box(.{
            .width = .percent(100),
            .height = .percent(100),
            .border_radius = .all(8),
            .background = .hex("#282a36"),
            .padding = .all(12),
            .margin = .{ .bottom = 32 },
        })({
            Custom.HtmlText(
                \\<code>fn createFiber(func: anytype, args: anytype, stack: Stack) !*Fiber </code>
            , .{ .text_color = .hex("#ffffff") });
        });

        Static.Box(.{
            .width = .percent(100),
            .height = .percent(100),
            .border_radius = .all(8),
            .background = .hex("#282a36"),
            .padding = .all(12),
            .margin = .{ .bottom = 32 },
        })({
            Custom.HtmlText(
                \\<code>fn spawnFibers(scheduler: Scheduler, slice_funcs: anytype, slice_args: anytype, stacks: []Stack) ![]*Fiber</code> 
            , .{ .text_color = .hex("#ffffff") });
        });

        Static.Box(.{
            .width = .percent(100),
            .height = .percent(100),
            .border_radius = .all(8),
            .background = .hex("#282a36"),
            .padding = .all(12),
            .margin = .{ .bottom = 32 },
        })({
            Custom.HtmlText(
                \\<code>fn runFibers(scheduler: Scheduler, []*Fiber) void</code> 
            , .{ .text_color = .hex("#ffffff") });
        });
    });
}

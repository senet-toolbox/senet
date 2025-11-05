const Fabric = @import("fabric");
const Signal = Fabric.Signal;

var counter: Signal(u32) = undefined;
var text: Signal([]const u8) = undefined;
fn init() void {
    counter.init(0);
    text.init("Is 0");
}

fn increment() void {
    counter.increment();
++    text.set(Fabric.fmtln("Is {d}", .{counter.get()}));
}

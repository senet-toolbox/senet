const Fabric = @import("fabric");
const Signal = Fabric.Signal;

var counter: Signal(u32) = undefined;
fn init() void {
    counter.init(0);
    counter.increment();
}

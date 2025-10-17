const Fabric = @import("fabric");
const Static = Fabric.Static;
const Pure = Fabric.Pure;
const Signal = Fabric.Signal;

var counter: Signal(u32) = undefined;

fn init() void {
    counter.init(0);
}

fn increment() void {
    counter.increment();
}

fn render() void {
    Static.Button(.{ .on_press = increment }).plain()({
        Pure.TextFmt("{d}", .{counter.get()}).plain();
    });
}

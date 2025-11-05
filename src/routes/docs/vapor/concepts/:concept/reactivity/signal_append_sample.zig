const std = @import("std");
const ArrayList = std.ArrayList;
const Fabric = @import("fabric");
const Signal = Fabric.Signal;

var list: Signal(ArrayList(u32)) = undefined;
fn init() void {
    list.init(ArrayList(u32).init(Fabric.lib.allocator_global));
    list.append(2);
}

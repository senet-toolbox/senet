const Fabric = @import("fabric");
const Signal = Fabric.Signal;

var show_notification: Signal(bool) = undefined;
fn init() void {
    show_notification.init(false);
    show_notification.set(true);
}

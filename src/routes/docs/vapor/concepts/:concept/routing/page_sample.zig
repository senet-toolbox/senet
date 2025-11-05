const Fabric = @import("fabric");
const Page = Fabric.Page;

// Page Initialization
pub fn init() void {
    Page(@src(), render, deinit);
}

// Page Deinitialization
pub fn deinit() void {
    Fabric.println("I get called when you navigate away from this page", .{});
}

pub fn render() void {
    Fabric.println("I get rendered when you navigate to this page", .{});
}

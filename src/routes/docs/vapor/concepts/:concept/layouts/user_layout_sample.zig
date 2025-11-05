const Fabric = @import("fabric");
const Menu = @import("Menu.zig");
fn user_layout(page: Fabric.PageFn) void {
    Fabric.Remember(@src())({
        Menu.render({});
    });
    @call(.auto, page, .{});
}

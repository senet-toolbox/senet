const Fabric = @import("fabric");
const FlexBox = Fabric.Static.FlexBox;
const AllocText = Fabric.Pure.AllocText;

const User = struct {
    name: []const u8,
    lastname: []const u8,
    age: u32,
};

fn Hello(user_name: []const u8) void {
    AllocText("Hello {s}!", .{user_name});
}

// Render
pub fn render(user: User) void {
    FlexBox(.{})({
        Hello(user.name);
    });
}

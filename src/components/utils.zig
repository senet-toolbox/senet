const Vapor = @import("vapor");
fn copy(text: []const u8) void {
    Vapor.Clipboard.copy(text);

}

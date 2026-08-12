const Vapor = @import("vapor");

pub fn render() void {
    Vapor.Center().size(.full).children({
        Vapor.Text("404 Not Found").fontSize(24).end();
    });
}

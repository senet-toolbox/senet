const Vapor = @import("vapor");

pub fn init() void {
    Vapor.Page(.{ .src = @src() }, render, null);
}

fn render() void {
    Vapor.Center().size(.full).direction(.column).spacing(16).children({
        Vapor.Image(.{ .src = "/assets/loli.png" })
            .width(.percent(20))
            .end();
        Vapor.Text("Page Not found").fontSize(32).end();
        Vapor.Button(Vapor.Kit.back, .{})
            .fontStyle(.italic)
            .duration(100)
            .pointer()
            .hover(.{
                .text_decoration = .underline,
                .text_color = .palette(.tint),
            })
            .children({
            Vapor.Text("Go Back").fontSize(18).end();
        });
    });
}

const Vapor = @import("vapor");

pub fn init() void {
    Vapor.Animation.init("square-dash")
        .at(0).set(.strokeDashoffset, 0)
        .at(100).set(.strokeDashoffset, -184)
        .duration(1000)
        .easing(.linear)
        .infinite()
        .build();
}

pub fn render() void {
    Vapor.Center().size(.full).children({
        Vapor.Svg(.{ .svg = @embedFile("loader.svg"), .override = true })
            .size(.px(36))
            .end();
    });
}

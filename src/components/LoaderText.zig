const Vapor = @import("vapor");

pub fn init() void {
    Vapor.Animation.init("sk-shimmer") // Option B: the sweep
        .at(0).set(.translateX, -260)
        .at(100).set(.translateX, 680)
        .duration(1400)
        .easing(.linear)
        .infinite()
        .build();
    Vapor.Animation.init("sk-pulse") // Option A: the breathe
        .at(0).set(.opacity, 0.07)
        .at(50).set(.opacity, 0.17)
        .at(100).set(.opacity, 0.07)
        .duration(1400)
        .easing(.easeInOut)
        .infinite()
        .build();
}

pub fn render() void {
    Vapor.Center().size(.full).children({
        Vapor.Svg(.{ .svg = @embedFile("loadertext.svg"), .override = true })
            .size(.full)
            .end();
    });
}
